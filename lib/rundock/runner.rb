require 'rundock'
require 'yaml'
require 'tempfile'

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
    attr_reader :scenario

    def initialize(options)
      @options = options
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

      if options['scenario_yaml'] =~ /^(http|https):\/\//
        # read from http/https
        open(options['scenario_yaml']) do |f|
          @scenario = parse_scenario_from_file(f)
        end
      else
        File.open(options['scenario_yaml']) do |f|
          @scenario = parse_scenario_from_file(f)
        end
      end
    end

    private

    def parse_scenario_from_file(file)
      scen = Scenario.new

      main  = nil
      nodes = nil
      tasks = nil

      YAML.load_documents(file).each_with_index do |data, idx|
        case idx
        when 0
          main  = data
        when 1
          nodes = data
        when 2
          tasks = data
        end
      end

      main.each do |k,v|
        node = Node.new

        if k == 'host'
          node.host = v
        else
          task = Task.new(v)
          node << task
        end
      end

      scen
    end
  end
end
