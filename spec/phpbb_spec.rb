require "spec_helper"
require "./phpbb.rb"

RSpec.describe PhpBB do
  context "logging in" do
    it "successfully logs in", :pending => true
    it "fails to log in when missing username", :pending => true
    it "fails to log in when missing password", :pending => true
    it "fails to log in with incorrect password", :pending => true
  end

  context "getting signature" do
    it "logs in when not already logged in", :pending => true
    it "does not log in again when already logged in", :pending => true
    it "returns signature", :pending => true
    it "uses cached signature when available", :pending => true
    it "returns new signature after update", :pending => true
  end

  context "setting signature" do
    it "logs in when not already logged in", :pending => true
    it "does not log in again when already logged in", :pending => true
    it "uses cached signature when available", :pending => true
    it "does not update signature if there is no change", :pending => true
    it "returns new signature after update", :pending => true
  end
end
