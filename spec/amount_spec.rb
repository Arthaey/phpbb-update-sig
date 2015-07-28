require "spec_helper"
require "./amount.rb"

RSpec.describe Amount do
  def expect_amount(amount, quantity, type)
    expect(amount.quantity).to eq(quantity)
    expect(amount.type).to eq(type)
  end

  context "creating new object" do
    it "accepts every available type" do
      Amount::TYPES.keys.each do |type|
        a = Amount.new(42, type)
        expect_amount(a, 42, type)
      end
    end

    it "fails for negative quantity" do
      expect{ Amount.new(-1, :decrement) }.to raise_error("Quantity must not be negative")
    end

    it "fails for absent quantity" do
      expect{ Amount.new(nil, :absolute) }.to raise_error("Quantity must not be nil")
    end

    it "fails for unrecognized type" do
      all_types = Amount::TYPES.keys.inspect
      expect{ Amount.new(1, :foo) }.to raise_error("Type foo is not one of #{all_types}")
    end

    it "parses number with -" do
      a = Amount.parse_string("-1")
      expect_amount(a, 1, :decrement)
    end

    it "parses number with no sign" do
      a = Amount.parse_string("1")
      expect_amount(a, 1, :absolute)
    end

    it "parses number with +" do
      a = Amount.parse_string("+1")
      expect_amount(a, 1, :increment)
    end

    it "rejects malformed strings" do
      expect(Amount.parse_string("NaN")).to be_nil
    end

  end

  context "to_s" do
    it "prepends - to decrement amounts" do
      a = Amount.new(42, :decrement)
      expect(a.to_s).to eq("-42")
    end

    it "prepends nothing to absolute amounts" do
      a = Amount.new(42, :absolute)
      expect(a.to_s).to eq("42")
    end

    it "prepends + to increment amounts" do
      a = Amount.new(42, :increment)
      expect(a.to_s).to eq("+42")
    end
  end

  context "equality" do
    it "Amount with same quantity and type is equal", :pending => true
    it "Amount with same quantity but different type is not equal", :pending => true
    it "Amount with same type but different quantity is not equal", :pending => true
    it "number with same quantity and type is equal", :pending => true
    it "number with same quantity but different type is not equal", :pending => true
    it "number with same type but different quantity is not equal", :pending => true
    it "string with same quantity and type is equal", :pending => true
    it "string with same quantity but different type is not equal", :pending => true
    it "string with same type but different quantity is not equal", :pending => true
  end

  context "updating based on another Amount" do
    before(:example) do
      @a = Amount.new(42, :absolute)
    end

    it "decrements quantity" do
      @a.update!(Amount.parse_string("-1"))
      expect_amount(@a, 41, :absolute)
    end

    it "sets quantity" do
      @a.update!(Amount.parse_string("37"))
      expect_amount(@a, 37, :absolute)
    end

    it "increments quantity" do
      @a.update!(Amount.parse_string("+1"))
      expect_amount(@a, 43, :absolute)
    end

    it "does nothing if other Amount is nil" do
      @a.update!(nil)
      expect_amount(@a, 42, :absolute)
    end
  end
end
