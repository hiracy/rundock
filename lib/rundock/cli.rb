require 'rundock'
require 'thor'

module Rundock
  class CLI < Thor
    DEFAULT_SCENARIO_FILE_PATH = './scenario.yml'
    DEFAULT_SSH_OPTIONS_DEFAULT_FILE_PATH = './default_ssh.yml'

    class_option :log_level, type: :string, aliases: ['-l'], default: 'info'
    class_option :color, type: :boolean, default: true

    def initialize(args, opts, config)
      super(args, opts, config)

      Rundock::Logger.level = ::Logger.const_get(options[:log_level].upcase)
      Rundock::Logger.formatter.colored = options[:color]
    end

    desc "version", "Print version"
    def version
      puts "#{Rundock::VERSION}"
    end

    desc "do [SCENARIO] [options]", "Run rundock from scenario file"
    option :sudo, type: :boolean, default: false
    option :default_ssh_opts_yaml, type: :string, aliases: ['-d'], default: DEFAULT_SSH_OPTIONS_DEFAULT_FILE_PATH
    def do(*scenario_file_path)
      scenario_file_path = [DEFAULT_SCENARIO_FILE_PATH] if scenario_file_path.empty?
      opts = {:scenario_yaml => scenario_file_path[0]}

      Runner.run(opts.merge(options))
    end

    desc "ssh [options]", "Run rundock ssh with various options"
    option :command, type: :string, aliases: ['-c'], banner: "NOTICE: Scenario's task is ignored."
    option :scenario_yaml, type: :string, aliases: ['-s'], default: DEFAULT_SCENARIO_FILE_PATH
    option :default_ssh_opts_yaml, type: :string, aliases: ['-d'], default: DEFAULT_SSH_OPTIONS_DEFAULT_FILE_PATH
    option :host, type: :string, aliases: ['-h']
    option :user, type: :string, aliases: ['-u']
    option :key, type: :string, aliases: ['-i']
    option :port, type: :numeric, aliases: ['-p']
    option :ssh_config, type: :string, aliases: ['-F']
    option :ask_password, type: :boolean, default: false
    option :sudo, type: :boolean, default: false
    def ssh
      opts = {}
      Runner.run(opts.merge(options))
    end
  end
end
