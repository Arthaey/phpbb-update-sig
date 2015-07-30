require "highline/import"
require "optparse"
require "yaml"

module SigUpdater
  class Config

    DEFAULT_CONFIG_FILENAME = "update-sig.yml"
    ENV_VAR_SITE_KEY     = "PHPBB_UPDATE_SIG_SITE"
    ENV_VAR_USERNAME_KEY = "PHPBB_UPDATE_SIG_USERNAME"
    ENV_VAR_PASSWORD_KEY = "PHPBB_UPDATE_SIG_PASSWORD"
    
    attr_reader :site, :username, :password

    def initialize(site, username, password)
      @site = site
      @username = username
      @password = password
    end

    def self.get_info(env = :test, config_filename = DEFAULT_CONFIG_FILENAME)
      config_file = get_config_file(config_filename)
      config = (env.nil? ? config_file : config_file[env])
      cmd_args = get_arguments()
      env_vars = get_env_vars()

      site     = config[:site]     || cmd_args[:site]     || env_vars[:site]
      username = config[:username] || cmd_args[:username] || env_vars[:username]
      password = config[:password] || cmd_args[:password] || env_vars[:password]

      raise "Site URL is required" if site.nil?
      raise "Username is required" if username.nil?

      if password.nil?
        password = ask("Password for #{username}: ") { |q| q.echo = false }
      end
      raise "Password required for user '#{username}'" if password.nil? or password.empty?

      Config.new(site, username, password)
    end

    private

    def self.get_config_file(config_filename)
      config = YAML.load_file(config_filename) rescue {}
      deep_symbolize_keys!(config)
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
        :site     => ENV[ENV_VAR_SITE_KEY],
        :username => ENV[ENV_VAR_USERNAME_KEY],
        :password => ENV[ENV_VAR_PASSWORD_KEY],
      }
    end

    def self.deep_symbolize_keys!(hash)
      deep_transform_keys!(hash) { |key| key.to_sym rescue key }
    end

    # From activesupport/lib/active_support/core_ext/hash/keys.rb
    def self.deep_transform_keys!(object, &block)
      case object
      when Hash
        object.keys.each do |key|
          value = object.delete(key)
          object[yield(key)] = deep_transform_keys!(value, &block)
        end
        object
      when Array
        object.map! {|e| deep_transform_keys!(e, &block) }
      else
        object
      end
    end

  end
end
