require 'rundock'
require 'yaml'
require 'tempfile'

module Rundock
  class Runner
    PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH = "#{File.dirname(__FILE__)}/default_ssh.yml"
    ScenarioNotFoundError = Class.new(StandardError)
    CommandArgNotFoundError = Class.new(StandardError)

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
      @scenario.run
    end

    def build(options)

      unless options['scenario_yaml'] && File.exist?(options['scenario_yaml'])
        raise ScenarioNotFoundError, "'#{options['scenario_yaml']}' scenario file is not found."
      end

      opts = YAML.load_file(options['default_ssh_opts_yaml'])
      opts.merge!(options)

      # parse scenario
      if options['scenario_yaml'] =~ /^(http|https):\/\//
        # read from http/https
        open(options['scenario_yaml']) do |f|
          @scenario = parse_scenario_from_file(f)
        end
      else
        File.open(options['scenario_yaml']) do |f|
          @scenario = parse_scenario_from_file(f, opts)
        end
      end
    end

    private

    def parse_scenario_from_file(file, options)
      scen = Scenario.new

      type = [:main, :node_info, :tasks]
      scenario_data = {}

      YAML.load_documents(file).each_with_index do |data, idx|
        scenario_data[type[idx]] = data
      end

      node = nil

      # use host option
      if options['host']
        raise CommandArgNotFoundError, %Q{"--command or -c" option is not specified.} unless options['command']
        ope = Array(Rundock::OperationFactory.instance(:command).create(Array(options['command']), nil))
        node = Node.new(options['host'], ope, build_backend(options['host'], nil, options))
        scen << node
        return scen
      end

      # use scenario file
      scenario_data[:main].each do |k,v|

        if k == 'node'
          node = Node.new(
            v['name'],
            build_operations(v, scenario_data[:tasks], options),
            build_backend(v, scenario_data[:node_info], options))
        end

        scen << node
      end

      scen
    end

    def build_operations(context, tasks, options)

      operations = []

      if options['command']
        Logger.debug(%Q{"--command or -c" option is specified and ignore scenario file.})
        operations << Rundock::OperationFactory.instance(:command).create(Array(options['command']), nil)
      end

      context.each do |k,v|
        if k != 'name'
          operations << Rundock::OperationFactory.instance(k.to_sym).create(Array(v), tasks)
        end
      end

      operations
    end

    def build_backend(host, node_info, options)

      opts = {}
      opts.merge!(options)

      backend_type = :local
      backend_type = :ssh if host !~ /localhost|127\.0\.0\.1/ || options['port'] || options['user']

      # update ssh options for node
      opts.merge!(node_info['ssh_opts']) if node_info && node_info['ssh_opts']

      Backend.create(backend_type, opts)
    end
  end
end
