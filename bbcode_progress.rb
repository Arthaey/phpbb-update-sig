require "./amount.rb"

module SigUpdater
  class BBCodeProgress

    ARG_REGEX = %r{-{0,2}(\w+)=(#{Amount::NUMBER_REGEX})?/?(#{Amount::NUMBER_REGEX})?}

    PROGRESS_REGEX = %r{\[progress=(\w+)\](\d+)/(\d+)\[/progress\]}

    SIG_REGEX = %r{(?:#{PROGRESS_REGEX} *)+}

    attr_reader :label, :value, :max

    def initialize(label, value, max = nil)
      @label = label
      self.value = value
      self.max = max
    end

    def value=(amount)
      set_variable(:@value, amount)
    end

    def max=(amount)
      set_variable(:@max, amount)
      raise "ERROR: Max must be an integer" if @max && @max.quantity % 1 != 0
    end

    def to_s
      if @max.nil?
        raise "ERROR[#{@label}]: must set @max before calling to_s"
      end

      # Scale value and max up to be integers with the same ratio, if needed.
      value = @value.quantity
      max = @max.quantity
      if @value.quantity % 1 != 0
        value *= 100
        max *= 100
      end

      "[progress=#{@label}]#{value.round}/#{max.round}[/progress]"
    end

    def self.update(old_sig, args)
      old_progress = self.parse_sig(old_sig)
      args_progress = self.parse_args(args)

      new_progress = self.update!(old_progress, args_progress)
      new_progress_sig = new_progress.map { |label, p| p.to_s }.join(" ")

      old_sig.sub(SIG_REGEX, new_progress_sig)
    end

    private

    def set_variable(variable, amount)
      return if amount.nil?
      case amount
        when Amount
          instance_variable_set(variable, amount)
        when Fixnum
          instance_variable_set(variable, Amount.new(amount, :absolute))
        when String
          instance_variable_set(variable, Amount.parse_string(amount))
      end
    end

    # Updates old_progress with new values from args_progress.
    def self.update!(old_progress, args_progress)
      if old_progress.any? { |label, p| p.max.nil? }
        $stderr.puts old_progress.inspect
        raise "ERROR: all old_progress items must have @max set"
      end

      not_updated = old_progress.map { |label, p| label }

      args_progress.each do |label, p|
        if old_p = old_progress[label]
          old_p.value.update!(p.value)
          old_p.max.update!(p.max)
          not_updated.delete(label)
        else
          $stderr.puts "WARNING: no such item '#{label}', will not create one"
        end
      end

      not_updated.each do |label|
        $stderr.puts "WARNING: did not update '#{label}'"
      end

      old_progress
    end

    # Returns an hash of BBCodeProgress items from command-line arguments.
    def self.parse_args(args)
      matches = args.join(" ").scan(ARG_REGEX)
      self.construct_hash(matches.map { |data| [data[0], data[1], data[4]] })
    end

    # Returns an hash of BBCodeProgress items from a BBCode signature.
    def self.parse_sig(sig)
      self.construct_hash(sig.scan(PROGRESS_REGEX))
    end

    def self.construct_hash(array_of_data)
      items = {}
      array_of_data.each do |data|
        label, value, max = *data
        if label && (value || max)
          p = BBCodeProgress.new(label, value, max)
          items[p.label.downcase] = p
        end
      end
      items
    end
  end
end
