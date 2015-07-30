require_relative "spec_helper"
require_relative "../lib/config"

RSpec.describe SigUpdater::Config do

  TEST_CONFIG_FILENAME = "spec/update-sig-test.yml"

  before(:context) do
    @env_var_site = ENV[SigUpdater::Config::ENV_VAR_SITE_KEY]
    @env_var_username = ENV[SigUpdater::Config::ENV_VAR_USERNAME_KEY]
    @env_var_password = ENV[SigUpdater::Config::ENV_VAR_PASSWORD_KEY]
  end

  after(:context) do
    set_env_vars(@env_var_site, @env_var_username, @env_var_password)
  end

  it "gets top-level info" do
    c = SigUpdater::Config.get_info(nil, TEST_CONFIG_FILENAME)
    expect(c.site).to eq("http://www.example.com/phpBB")
    expect(c.username).to eq("your-username-here")
    expect(c.password).to eq("your-password-here")
  end

  it "gets test info" do
    c = SigUpdater::Config.get_info(:test, TEST_CONFIG_FILENAME)
    expect(c.site).to eq("http://localhost/phpBB")
    expect(c.username).to eq("test-username-here")
    expect(c.password).to eq("test-password-here")
  end

  it "gets information from command-line arguments" do
    ARGV = [
      "--site=http://localhost/arg",
      "--username=arg-username",
      "--password=arg-password",
    ]
    c = SigUpdater::Config.get_info(:nothing, TEST_CONFIG_FILENAME)
    expect(c.site).to eq("http://localhost/arg")
    expect(c.username).to eq("arg-username")
    expect(c.password).to eq("arg-password")
  end

  it "gets information from environment variables" do
    set_env_vars("http://localhost/env", "env-username", "env-password")
    c = SigUpdater::Config.get_info(:nothing, TEST_CONFIG_FILENAME)
    expect(c.site).to eq("http://localhost/env")
    expect(c.username).to eq("env-username")
    expect(c.password).to eq("env-password")
    set_env_vars(nil, nil, nil)
  end

  it "fails when no site is given" do
    expect { SigUpdater::Config.get_info(:no_site, TEST_CONFIG_FILENAME) }
        .to raise_error("Site URL is required")
  end

  it "fails when no username is given" do
    expect { SigUpdater::Config.get_info(:no_username, TEST_CONFIG_FILENAME) }
        .to raise_error("Username is required")
  end

  it "fails when no password is given", :skip => true do
    # FIXME: stub stdin to return nothing
    expect { SigUpdater::Config.get_info(:no_password, TEST_CONFIG_FILENAME) }
        .to raise_error("Password required for user 'test-username-here'")
  end

  it "gets password from user prompt", :skip => true do
    # FIXME: stub stdin to return "prompt-password"
    c = SigUpdater::Config.get_info(:no_password, TEST_CONFIG_FILENAME)
    expect(c.site).to eq("http://localhost/phpBB")
    expect(c.username).to eq("test-username")
    expect(c.password).to eq("prompt-password")
  end

  def set_env_vars(site, username, password)
    ENV[SigUpdater::Config::ENV_VAR_SITE_KEY] = site
    ENV[SigUpdater::Config::ENV_VAR_USERNAME_KEY] = username
    ENV[SigUpdater::Config::ENV_VAR_PASSWORD_KEY] = password
  end
end
