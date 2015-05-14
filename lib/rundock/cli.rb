require 'rundock'
require 'thor'

module Rundock
  class CLI < Thor
    DEFAULT_SCENARIO_FILE_PATH = './scenario.yml'

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

    desc "do [SCENARIO]", "Run rundock from scenario file"
    option :sudo, type: :boolean, default: false
    def do(*scenario_file_path)
      scenario_file_path = [DEFAULT_SCENARIO_FILE_PATH] if scenario_file_path.empty?
      run(scenario_file_path[0], options)
    end

    desc "ssh [options]", "Run rundock ssh with various options"
    option :command, type: :string, aliases: ['-c']
    option :scenario_yaml, type: :string, aliases: ['-y'], default: DEFAULT_SCENARIO_FILE_PATH
    option :host, type: :string, aliases: ['-h']
    option :user, type: :string, aliases: ['-u']
    option :key, type: :string, aliases: ['-i']
    option :port, type: :numeric, aliases: ['-p']
    option :ask_password, type: :boolean, default: false
    option :sudo, type: :boolean, default: false
    def ssh
      run(options[:scenario_yaml], options)
    end

    private

    def run(scenario_yml, options)
      Logger.info "Starting Rundock..."
    end
  end
end
