require 'rundock'
require 'yaml'

module Rundock
  class Runner
    PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH = "#{File.dirname(__FILE__)}/ssh_options_default.yml"
    ScenarioNotFoundError = Class.new(StandardError)

    class << self
      def run(options)
        Logger.info "Starting Rundoc:"

        runner = self.new(options)
        runner.build(options)
        runner.run
      end
    end

    attr_reader :backend
    attr_reader :scenarios

    def initialize(options)
      @options = options
      @scenarios = Scenarios.new
    end

    def run
    end

    def build(options)

      unless options['scenario_yaml'] && File.exist?(options['scenario_yaml'])
        raise ScenarioNotFoundError, "'#{options['scenario_yaml']}' scenario file is not found."
      end
      unless options['ssh_opts_yaml'] && File.exist?(options['ssh_opts_yaml'])
        options['ssh_opts_yaml'] = PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH
      end

      scen      = nil
      tasks     = nil
      host_opts = nil

      File.open(options['scenario_yaml']) do |f|
        YAML.load_documents(f).each_with_index do |data, idx|
          case idx
          when 0
            scen = data
          when 1
            tasks = data
          when 2
            host_opts = data
          end
        end
      end

      p scen
      p tasks
      p host_opts
    end
  end
end
