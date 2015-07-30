require "spec_helper"
require "./config.rb"
require "./phpbb.rb"

# integration tests
RSpec.describe PhpBB do
  before(:context) do
    @config = SigUpdater::Config.get_info(true)
    @site = @config.site
    @test_user = @config.username
    @test_pass = @config.password
  end

  context "logging in" do
    it "successfully logs in" do
      phpbb = PhpBB.new(@site, @test_user, @test_pass)
      phpbb.login!
      expect(phpbb.logged_in).to be true
    end

    it "fails to log in when missing username" do
      phpbb = PhpBB.new(@site, nil, @test_pass)
      expect{ phpbb.login! }.to raise_error("Could not log in as user ''")
      expect(phpbb.logged_in).to be false
    end

    it "fails to log in when missing password" do
      phpbb = PhpBB.new(@site, @test_user, nil)
      expect{ phpbb.login! }.to raise_error("Could not log in as user '#{@test_user}'")
      expect(phpbb.logged_in).to be false
    end

    it "fails to log in with incorrect password" do
      phpbb = PhpBB.new(@site, @test_user, @test_pass + "incorrect")
      expect{ phpbb.login! }.to raise_error("Could not log in as user '#{@test_user}'")
      expect(phpbb.logged_in).to be false
    end
  end

  context "getting signature" do
    it "logs in when not already logged in" do
      phpbb = PhpBB.new(@site, @test_user, @test_pass)
      expect(phpbb.logged_in).to be false
      expect(phpbb.signature).to_not be_nil
      expect(phpbb.logged_in).to be true
    end

    it "does not log in again when already logged in", :pending => true
    it "returns signature", :pending => true
    it "uses cached signature when available", :pending => true
    it "returns new signature after update", :pending => true
  end

  context "setting signature" do
    it "logs in when not already logged in" do
      phpbb = PhpBB.new(@site, @test_user, @test_pass)
      expect(phpbb.logged_in).to be false
      expect(phpbb.signature = "foo").to eq("foo")
      expect(phpbb.logged_in).to be true
    end

    it "does not log in again when already logged in", :pending => true
    it "uses cached signature when available", :pending => true
    it "does not update signature if there is no change", :pending => true

    it "returns new signature after update" do
      phpbb = PhpBB.new(@site, @test_user, @test_pass)
      expect(phpbb.signature = "foo").to eq("foo")
      expect(phpbb.signature).to eq("foo")
      expect(phpbb.signature = "bar").to eq("bar")
      expect(phpbb.signature).to eq("bar")
    end
  end
end
