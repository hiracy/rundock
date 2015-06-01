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

      unless options['default_ssh_opts_yaml'] && File.exist?(options['default_ssh_opts_yaml'])
        options['default_ssh_opts_yaml'] = PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH
      end

      opt_ssh_user = options['user']
      opt_ssh_key = options['key']
      opt_ssh_port = options['port']

      # parse default ssh options
      ssh_opts_default = YAML.load_file(options['default_ssh_opts_yaml'])
      options.merge!(ssh_opts_default)
      
      # fix ssh options if args specified
      options['user'] = opt_ssh_user
      options['key'] = opt_ssh_key
      options['port'] = opt_ssh_port

      # parse scenario
      if options['scenario_yaml'] =~ /^(http|https):\/\//
        # read from http/https
        open(options['scenario_yaml']) do |f|
          @scenario = parse_scenario_from_file(f)
        end
      else
        File.open(options['scenario_yaml']) do |f|
          @scenario = parse_scenario_from_file(f, options)
        end
      end
    end

    private

    def parse_scenario_from_file(file, options)
      scen = Scenario.new

      main  = nil
      node_info = nil
      tasks = nil

      YAML.load_documents(file).each_with_index do |data, idx|
        case idx
        when 0
          main  = data
        when 1
          node_info = data
        when 2
          tasks = data
        end
      end

      node = nil

      # use host option
      if options['host']
        raise CommandArgNotFoundError, %Q{"--command or -c" option is not specified.} unless options['command']
        ope = Rundock::Operation::Command.new(:command,  options['command'])
        node = Node.new(options['host'], ope, build_backend(options['host'], nil, options))
        scen << node
        return scen
      end

      # use scenario file
      main.each do |k,v|

        if k == 'node'
          node = Node.new(
            v['name'],
            build_operations(v, options),
            build_backend(v, node_info, options))
        end

        scen << node
      end

      scen
    end

    def build_operations(content, options)

      operations = []

      if options['command']
        Logger.debug(%Q{"--command or -c" option is specified and ignore scenario file.})
        operations << Rundock::Operation::Command.new(:command,  options['command'])
      else

        content.each do |k,v|
          if k != 'name'
            operations << Rundock::Operation::Base.new(k.to_sym, v)
          end
        end
      end

      operations
    end

    def build_backend(host, node_info, options)

      opts = {}
      opts.merge!(options)

      backend_type = :exec
      backend_type = :ssh if host !~ /localhost|127\.0\.0\.1/

      # update ssh options for node
      opts.merge!(node_info['ssh_opts']) if node_info['ssh_opts']

      Backend.create(backend_type, options)
    end
  end
end
