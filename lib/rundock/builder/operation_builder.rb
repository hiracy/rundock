module Rundock
  module Builder
    class OperationBuilder < Base
      def build_first(scenario, node_info, tasks)
        if @options[:hostgroup] && !@options[:command]
          raise CommandArgNotFoundError, %("--command or -c" option is required if hostgroup specified.)
        end

        node = nil
        scen = Scenario.new
        node_attributes = { :task => {} }
        tasks.each { |k, v| node_attributes[:task][k] = v } if tasks
        scen.node_info = node_info
        scen.tasks = tasks

        # use scenario file
        scenario.each do |n|
          scen.nodes.push(node) if node

          n.deep_symbolize_keys.each do |k, v|
            if k == :node
              backend = BackendBuilder.new(@options, v, node_info).build
              node = Node.new(v, backend)
              node_attributes[:nodename] = v

              if @options[:command]
                node.add_operation(build_cli_command_operation(@options[:command], @options))
              end
            else
              if @options[:command] && (k == :command || k == :task)
                Logger.debug(%("--command or -c" option is specified and ignore scenario file.))
                next
              end

              next unless node

              ope = build_operations(k, Array(v), node_attributes, @options)
              node.add_operation(ope)
            end
          end
        end

        scen.nodes.push(node) if node
        scen
      end

      def build_task(tasks, backend, node_attributes)
        node = Node.new(node_attributes[:nodename], backend)
        scen = Scenario.new

        tasks.each do |k, v|
          ope = build_operations(k, Array(v), node_attributes, nil)
          node.add_operation(ope)
        end

        scen.nodes.push(node) if node
        scen
      end

      def build_cli
        scen = Scenario.new

        @options[:host].split(',').each do |host|
          backend = BackendBuilder.new(@options, host, nil).build
          node = Node.new(host, backend)
          node.add_operation(build_cli_command_operation(@options[:command], @options))
          scen.nodes.push(node)
        end

        scen
      end

      private

      def build_cli_command_operation(command, cli_options)
        node_attributes = {}
        node_attributes[:errexit] = !cli_options[:run_anyway]
        Rundock::OperationFactory.instance(:command).create(Array(command), nil)
      end

      def build_operations(ope_type, ope_content, node_attributes, cli_options)
        node_attributes[:errexit] = !cli_options[:run_anyway] if cli_options
        node_attributes[:errexit] = true if cli_options.nil?
        Rundock::OperationFactory.instance(ope_type).create(Array(ope_content), node_attributes)
      end
    end
  end
end
