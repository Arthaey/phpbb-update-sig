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

  def ==(other)
    case other
      when Amount
        @quantity == other.quantity && @type == other.type
      when Fixnum
        @quantity == other && @type == :absolute
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
end
