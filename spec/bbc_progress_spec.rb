require "spec_helper"
require "./bbcode_progress.rb"

RSpec.describe BBCodeProgress do
  context "creating new object" do
    it "sets label and value" do
      p = BBCodeProgress.new("label", 1)
      expect(p.label).to eq("label")
      expect(p.value).to eq(1)
      expect(p.max).to be_nil
    end

    it "sets label, value, and max" do
      p = BBCodeProgress.new("label", 1, 42)
      expect(p.label).to eq("label")
      expect(p.value).to eq(1)
      expect(p.max).to eq(42)
    end

    it "generates BBCode" do
      p = BBCodeProgress.new("label", 1, 42)
      expect(p.to_s).to eq("[progress=label]1/42[/progress]")
    end

    it "fails if max is absent before calling to_s" do
      p = BBCodeProgress.new("label", 1)
      expect{p.to_s}.to raise_error("ERROR[label]: must set @max before calling to_s")
    end
  end


  context "parsing command-line arguments" do
    it "parses item with leading --", :pending => true
    it "parses item without leading --", :pending => true
    it "rejects item with no value", :pending => true
    it "parses item with value", :pending => true
    it "parses item with max", :pending => true
    it "parses item with value and max", :pending => true
    it "parses item with fractional value", :pending => true
    it "parses item incrementing value", :pending => true
    it "parses item incrementing max", :pending => true
    it "parses item incrementing value and max", :pending => true
    it "parses item decrementing value", :pending => true
    it "parses item decrementing max", :pending => true
    it "parses item decrementing value and max", :pending => true
    it "parses multiple items", :pending => true
  end

  context "parsing signature" do
    it "parses item with value and max", :pending => true
    it "parses multiple items", :pending => true
  end

  context "updates progress" do
    it "replaces value", :pending => true
    it "replaces max", :pending => true
    it "replaces value and max", :pending => true
    it "preserves leading part of signature", :pending => true
    it "preserves trailing part of signature", :pending => true
    it "preserves leading & trailing parts of signature", :pending => true
    it "fails if max is absent", :pending => true
    it "warns when an item is not updated", :pending => true
    it "warns when an option does not match any items", :pending => true
    it "matches items case-insensitively", :pending => true
  end
end
