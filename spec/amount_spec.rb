require "spec_helper"
require "./amount.rb"

RSpec.describe Amount do
  context "creating new object" do
    it "accepts every available type", :pending => true
    it "fails for absent quantity", :pending => true
    it "fails for unrecognized type", :pending => true
    it "parses number with -", :pending => true
    it "parses number with no sign", :pending => true
    it "parses number with +", :pending => true
    it "rejects malformed strings", :pending => true
  end

  context "to_s" do
    it "prepends - to decrement amounts", :pending => true
    it "prepends nothing to absolute amounts", :pending => true
    it "prepends + to increment amounts", :pending => true
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
    it "decrements quantity", :pending => true
    it "sets quantity", :pending => true
    it "increments quantity", :pending => true
    it "does nothing if other Amount is nil", :pending => true
  end
end
