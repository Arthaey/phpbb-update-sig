require "highline/import"
require "optparse"
require "yaml"

module SigUpdater
  class Config

    CONFIG_FILENAME = "update-sig.yml"
    
    attr_reader :site, :username, :password

    def initialize(site, username, password)
      @site = site
      @username = username
      @password = password
    end

    def self.get_info(env = :test)
      config_file = get_config_file()
      config = (env.nil? ? config_file : config_file[env])
      cmd_args = get_arguments()
      env_vars = get_env_vars()

      site     = config_file[:site]     || cmd_args[:site]     || env_vars[:site]
      username = config_file[:username] || cmd_args[:username] || env_vars[:username]
      password = config_file[:password] || cmd_args[:password] || env_vars[:password]

      raise "Site URL is required" if site.nil?
      raise "Username is required" if username.nil?

      if password.nil?
        password = ask("Password for #{username}: ") { |q| q.echo = false }
      end
      raise "Password required for user '#{username}'" if password.nil?

      Config.new(site, username, password)
    end

    private

    def self.get_config_file
      config = YAML.load_file("update-sig.yml") rescue {}
      config.transform_keys!{ |key| key.to_sym rescue key }
      config
    end

    def self.get_arguments
      options = {}

      option_parser = OptionParser.new do |opts|
        opts.banner = "USAGE: #{$0} --username=USERNAME --site=URL --label=value[/max] ..."

        opts.on("-s", "--site=URL", "phpBB forum website URL") do |arg|
          arg.chop! if arg.end_with?("/")
          options[:site] = arg
        end

        opts.on("-u", "--username=USERNAME", "phpBB forum username") do |arg|
          options[:username] = arg
        end

        opts.on("-p", "--password=PASSWORD", "phpBB forum password") do |arg|
          options[:password] = arg
        end
      end

      # Keep any unknown options; these will be the progress items.
      begin
        option_parser.parse!
      rescue OptionParser::InvalidOption => e
        e.recover ARGV
      end

      options
    end

    def self.get_env_vars
      {
        :username => ENV["PHPBB_UPDATE_SIG_USERNAME"],
        :password => ENV["PHPBB_UPDATE_SIG_PASSWORD"],
      }
    end

  end
end

# File activesupport/lib/active_support/core_ext/hash/keys.rb, line 19
class Hash
  def transform_keys!
    return enum_for(:transform_keys!) unless block_given?
    keys.each do |key|
      self[yield(key)] = delete(key)
    end
    self
  end
end
