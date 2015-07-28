class BBCodeProgress

  ARG_REGEX = %r{-{0,2}(\w+)=(\d+)?/?(\d+)?}

  PROGRESS_REGEX = %r{\[progress=(\w+)\](\d+)/(\d+)\[/progress\]}

  SIG_REGEX = %r{(?:#{PROGRESS_REGEX} *)+}

  attr_reader :label, :value, :max

  def initialize(label, value, max = nil)
    @label = label
    self.value = value
    self.max = max
  end

  def value=(num)
    @value = num.to_i unless num.nil?
  end

  def max=(num)
    @max = num.to_i unless num.nil?
  end

  def to_s
    if @max.nil?
      raise "ERROR[#{@label}]: must set @max before calling to_s"
    end
    "[progress=#{@label}]#{@value}/#{@max}[/progress]"
  end

  def self.update(old_sig, args)
    old_progress = self.parse_sig(old_sig)
    args_progress = self.parse_args(args)

    new_progress = self.update!(old_progress, args_progress)
    new_progress_sig = new_progress.map { |label, p| p.to_s }.join(" ")

    old_sig.sub(SIG_REGEX, new_progress_sig)
  end

  private

  # Updates old_progress with new values from args_progress.
  def self.update!(old_progress, args_progress)
    if old_progress.any? { |label, p| p.max.nil? }
      $stderr.puts old_progress.inspect
      raise "ERROR: all old_progress items must have @max set"
    end

    not_updated = old_progress.map { |label, p| label }

    args_progress.each do |label, p|
      if old_p = old_progress[label]
        old_p.value = p.value
        old_p.max = p.max unless p.max.nil?
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

  # TODO: support +N values to make incrementing easier.
  # TODO: support 0.N => N values.
  # Returns an hash of BBCodeProgress items from command-line arguments.
  def self.parse_args(args)
    self.construct_hash(args.join(" ").scan(ARG_REGEX))
  end

  # Returns an hash of BBCodeProgress items from a BBCode signature.
  def self.parse_sig(sig)
    self.construct_hash(sig.scan(PROGRESS_REGEX))
  end

  def self.construct_hash(array_of_data)
    items = {}
    array_of_data.each do |data|
      # label is required; at least one of value or max is required
      if data[0] && (data[1] || data[2])
        p = BBCodeProgress.new(*data)
        items[p.label.downcase] = p
      end
    end
    items
  end
end
