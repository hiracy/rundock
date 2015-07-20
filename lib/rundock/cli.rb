require 'rundock'
require 'thor'

module Rundock
  class CLI < Thor
    DEFAULT_SCENARIO_FILE_PATH = './scenario.yml'
    DEFAULT_SSH_OPTIONS_DEFAULT_FILE_PATH = './default_ssh.yml'
    DEFAULT_HOSTGROUP_FILE_PATH = './hostgroup.yml'

    class_option :log_level, type: :string, aliases: ['-l'], default: 'info'
    class_option :color, type: :boolean, default: true
    class_option :header, type: :boolean, default: true

    def initialize(args, opts, config)
      super(args, opts, config)

      Rundock::Logger.level = ::Logger.const_get(options[:log_level].upcase)
      Rundock::Logger.formatter.colored = options[:color]
      Rundock::Logger.formatter.show_header = options[:header]
    end

    desc 'version', 'Print version'
    def version
      puts "#{Rundock::VERSION}"
    end

    desc 'do [SCENARIO] [options]', 'Run rundock from scenario file'
    option :sudo, type: :boolean, default: false
    option :scenario, type: :string, aliases: ['-s'], default: DEFAULT_SCENARIO_FILE_PATH
    option :default_ssh_opts, type: :string, aliases: ['-d'], default: DEFAULT_SSH_OPTIONS_DEFAULT_FILE_PATH
    option :run_anyway, type: :boolean
    def do(*scenario_file_path)
      scenario_file_path = [DEFAULT_SCENARIO_FILE_PATH] if scenario_file_path.empty?
      opts = { :scenario => scenario_file_path[0] }

      Runner.run(opts.merge(options))
    end

    desc 'ssh [options]', 'Run rundock ssh with various options'
    option :command, type: :string, aliases: ['-c']
    option :default_ssh_opts, type: :string, aliases: ['-d'], default: DEFAULT_SSH_OPTIONS_DEFAULT_FILE_PATH
    option :host, type: :string, aliases: ['-h'], banner: 'You can specify comma separated hosts.[ex: host1,host2,..]'
    option :hostgroup, type: :string, aliases: ['-g']
    option :user, type: :string, aliases: ['-u']
    option :key, type: :string, aliases: ['-i']
    option :port, type: :numeric, aliases: ['-p']
    option :ssh_config, type: :string, aliases: ['-F']
    option :ask_password, type: :boolean, default: false
    option :sudo, type: :boolean, default: false
    option :run_anyway, type: :boolean, default: false
    def ssh
      opts = {}

      Runner.run(opts.merge(options.deep_symbolize_keys))
    end
  end
end
