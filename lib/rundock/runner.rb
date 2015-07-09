require 'rundock'
require 'yaml'
require 'tempfile'
require 'open-uri'

module Rundock
  class Runner
    PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH = "#{Gem::Specification.find_by_path('rundock').full_gem_path}/default_ssh.yml"
    ScenarioNotFoundError = Class.new(StandardError)
    CommandArgNotFoundError = Class.new(StandardError)

    class << self
      def run(options)
        Logger.info 'Starting Rundoc:'

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
      if options['scenario_yaml']
        unless FileTest.exist?(options['scenario_yaml'])
          raise ScenarioNotFoundError, "'#{options['scenario_yaml']}' scenario file is not found."
        end

        # parse scenario
        if options['scenario_yaml'] =~ %r{^(http|https)://}
          # read from http/https
          open(options['scenario_yaml']) do |f|
            @scenario = parse_scenario(f, options)
          end
        else
          File.open(options['scenario_yaml']) do |f|
            @scenario = parse_scenario(f, options)
          end
        end
      else
        @scenario = parse_scenario(nil, options)
      end
    end

    private

    def parse_default_ssh(options)
      opts = {}

      if options['default_ssh_opts_yaml'] && FileTest.exist?(options['default_ssh_opts_yaml'])
        def_ssh_file = options['default_ssh_opts_yaml']
      else
        def_ssh_file = PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH
      end

      File.open(def_ssh_file) do |f|
        YAML.load_documents(f) do |y|
          y.each do |k, v|
            opts["#{k}_ssh_default"] = v
          end
        end
      end

      opts
    end

    def parse_scenario(scen_file, options)
      # parse default ssh file
      opts = parse_default_ssh(options)
      opts.merge!(options)

      scen = Scenario.new

      # no use scenario file
      if opts['host']
        scen << build_no_scenario_node_operation(opts)
        return scen
      end

      type = [:main, :node_info, :tasks]
      scenario_data = {}

      if scen_file
        YAML.load_documents(scen_file).each_with_index do |data, idx|
          scenario_data[type[idx]] = data
        end
      end

      node = nil

      # use scenario file
      scenario_data[:main].each do |n|
        scen << node if node

        n.each do |k, v|
          if k == 'node'
            node = Node.new(
              v,
              build_backend(v, scenario_data[:node_info], opts))
          else
            ope = build_operations(k, v, scenario_data[:tasks], opts)
            node.add_operation(ope) if node
          end
        end
      end

      scen << node if node
      scen
    end

    def build_no_scenario_node_operation(options)
      raise CommandArgNotFoundError, %("--command or -c" option is not specified.) unless options['command']

      node_info = { options['host'] => { 'ssh_opts' => {} } }

      %w(user key port ssh_config ask_password sudo).each { |o| node_info[options['host']]['ssh_opts'][o] = options[o] if options[o]  }

      node = Node.new(options['host'], build_backend(options['host'], node_info, options))
      node.add_operation(Rundock::OperationFactory.instance(:command).create(Array(options['command']), nil))
      node
    end

    def build_operations(ope_type, ope_content, tasks, options)
      if options['command']
        Logger.debug(%("--command or -c" option is specified and ignore scenario file.))
        return Rundock::OperationFactory.instance(:command).create(Array(options['command']), nil)
      end

      Rundock::OperationFactory.instance(ope_type.to_sym).create(Array(ope_content), tasks)
    end

    def build_backend(host, node_info, options)
      opts = {}

      if !node_info ||
         !node_info[host]
        node_info = { host => {} }
      end
      node_info[host]['ssh_opts'] = {} unless node_info[host]['ssh_opts']
      is_local = host =~ /localhost|127\.0\.0\.1/

      # replace default ssh options if exists
      options.keys.select { |o| o =~ /(\w+)_ssh_default$/ }.each do |oo|
        opt = oo.gsub(/_ssh_default/, '')
        # no use default ssh options if local
        # (like docker or localhost with port access host should not use default ssh options)
        node_info[host]['ssh_opts'][opt] = options[oo] if !is_local && !node_info[host]['ssh_opts'][opt]
      end

      if is_local &&
         !node_info[host]['ssh_opts']['port'] &&
         !node_info[host]['ssh_opts']['user'] &&
         !node_info[host]['ssh_opts']['ssh_config']
        backend_type = :local
      else
        backend_type = :ssh
        opts['host'] = host
      end

      opts.merge!(options)

      # update ssh options for node from node_info
      opts.merge!(node_info[host]['ssh_opts'])
      # delete trash ssh_options(node[host::ssh_options])
      node_info[host].delete('ssh_opts')

      # add any attributes for host from node_info
      opts.merge!(node_info[host])
      Backend.create(backend_type, opts)
    end
  end
end
