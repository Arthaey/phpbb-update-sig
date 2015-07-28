class Amount

  TYPES = {
    :decrement => -1,
    :absolute  =>  0,
    :increment =>  1,
  }

  attr_reader :quantity, :type

  def initialize(quantity, type)
    raise "Quantity must not be nil" if quantity.nil?
    raise "Type #{type} is not one of #{TYPES}" unless TYPES.has_key?(type)
    @quantity = quantity
    @type = type
  end

  def update(amount)
    return self if amount.nil?

    case amount.type
      when :decrement
        @quantity -= amount.quantity
      when :absolute
        @quantity = amount.quantity
      when :increment
        @quantity += amount.quantity
    end
  end

  def ==(other)
    case other
      when Amount
        @quantity == other.quantity && @type == other.type
      when Fixnum
        @quantity == other && @type == :absolute
      when String
        self == Amount.parse_string(other)
    end
  end

  def to_s
    case @type
      when :decrement
        "-#{@quantity}"
      when :absolute
        "#{@quantity}"
      when :increment
        "+#{@quantity}"
    end
  end

  def self.parse_string(input)
    if input =~ /([+-]?)(\d+)/
      quantity = $2.to_i
      case $1
        when "-"
          return Amount.new(quantity, :decrement)
        when ""
          return Amount.new(quantity, :absolute)
        when "+"
          return Amount.new(quantity, :increment)
      end
    end
    return nil
  end
end
