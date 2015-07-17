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

        # use host specified
        return build_scenario_with_host(opts) if opts['host']

        # use scenario file
        build_scenario(opts)
      end

      private

      def build_scenario_with_host(options)
        raise CommandArgNotFoundError, %("--command or -c" option is not specified.) unless options['command']

        scen = Scenario.new

        options['host'].split(',').each do |host|
          backend = BackendBuilder.new(options, host, nil).build
          node = Node.new(host, backend)
          node.add_operation(Rundock::OperationFactory.instance(:command).create(Array(options['command']), nil))
          scen << node
        end

        scen
      end

      def build_scenario(options)
        if options['hostgroup'] && !options['command']
          raise CommandArgNotFoundError, %("--command or -c" option is required if hostgroup specified.)
        end

        type = [:main, :node_info, :tasks]
        scenario_data = {}

        if @scenario_file
          YAML.load_documents(@scenario_file).each_with_index do |data, idx|
            scenario_data[type[idx]] = data
          end
        end

        node = nil
        scen = Scenario.new

        # use scenario file
        scenario_data[:main].each do |n|
          scen << node if node

          n.each do |k, v|
            if k == 'node'
              backend = BackendBuilder.new(options, v, scenario_data[:node_info]).build
              node = Node.new(v, backend)

              if options['command']
                node.add_operation(
                  Rundock::OperationFactory.instance(:command).create(Array(options['command']), nil))
              end
            else

              if options['command'] && (k == 'command' || k == 'task')
                Logger.debug(%("--command or -c" option is specified and ignore scenario file.))
                next
              end

              ope = build_operations(k, v, scenario_data[:tasks], options)
              node.add_operation(ope) if node
            end
          end
        end

        scen << node if node
        scen
      end

      def build_operations(ope_type, ope_content, tasks, options)
        Rundock::OperationFactory.instance(ope_type.to_sym).create(Array(ope_content), tasks)
      end
    end
  end
end
