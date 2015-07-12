require 'yaml'

module Rundock
  module Builder
    class ScenarioBuilder < Base
      CommandArgNotFoundError = Class.new(StandardError)

      def initialize(options, scenario_file_data)
        super(options)
        @scenario_file = scenario_file_data
        @default_ssh_builder = DefaultSshBuilder.new(@options)
      end

      def build
        # parse default ssh file
        opts = @default_ssh_builder.build
        opts.merge!(@options)

        scen = Scenario.new

        # no use scenario file
        if opts['host']
          scen << build_no_scenario_node_operation(opts)
          return scen
        end

        type = [:main, :node_info, :tasks]
        scenario_data = {}

        if @scenario_file
          YAML.load_documents(@scenario_file).each_with_index do |data, idx|
            scenario_data[type[idx]] = data
          end
        end

        node = nil

        # use scenario file
        scenario_data[:main].each do |n|
          scen << node if node

          n.each do |k, v|
            if k == 'node'
              backend = BackendBuilder.new(opts, v, scenario_data[:node_info]).build
              node = Node.new(v, backend)
            else
              ope = build_operations(k, v, scenario_data[:tasks], opts)
              node.add_operation(ope) if node
            end
          end
        end

        scen << node if node
        scen
      end

      private

      def build_no_scenario_node_operation(options)
        raise CommandArgNotFoundError, %("--command or -c" option is not specified.) unless options['command']

        node_info = { options['host'] => { 'ssh_opts' => {} } }

        %w(user key port ssh_config ask_password sudo).each { |o| node_info[options['host']]['ssh_opts'][o] = options[o] if options[o]  }

        backend = BackendBuilder.new(options, options['host'], node_info).build
        node = Node.new(options['host'], backend)
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
    end
  end
end
