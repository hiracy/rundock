module Rundock
  module Builder
    class OperationBuilder < Base
      def build_first(scenario, node_info, tasks)
        if @options[:hostgroup] && !@options[:command]
          raise CommandArgNotFoundError, %("--command or -c" option is required if hostgroup specified.)
        end

        node = nil
        scen = Scenario.new
        node_attribute = Rundock::Attribute::NodeAttribute.new(task_info: {})
        tasks.each { |k, v| node_attribute.task_info[k] = v } if tasks
        scen.node_info = node_info
        scen.node_info = {} unless node_info
        scen.tasks = tasks

        # use scenario file
        scenario.each do |n|
          scen.nodes.push(node) if node

          n.deep_symbolize_keys.each do |k, v|
            if k == :node
              node_attribute.finalize_node
              backend_builder = BackendBuilder.new(@options, v, node_info)
              backend = backend_builder.build

              node = Node.new(v, backend)
              node_attribute.nodename = v
              scen.node_info[v.to_sym] = node_attribute.nodeinfo = backend_builder.parsed_options

              if @options[:command]
                node.add_operation(build_cli_command_operation(@options[:command], node_attribute, @options))
              end
            elsif k == :hook
              node_attribute.enable_hooks = Array(v)
              node.hooks = HookBuilder.new(@options).build(Array(v)) if node
            else

              next unless node

              ope = build_operations(k, Array(v), node_attribute, @options, false)
              node.add_operation(ope) if ope
            end
          end
        end

        scen.nodes.push(node) if node
        scen
      end

      def build_task(tasks, backend, node_attribute)
        node = Node.new(node_attribute.nodename, backend)
        node.hooks = HookBuilder.new(nil).build_from_attributes(node_attribute.nodeinfo)
        scen = Scenario.new

        tasks.each do |k, v|
          ope = build_operations(k, Array(v), node_attribute, nil, true)
          node.add_operation(ope) if ope
        end

        scen.nodes.push(node) if node
        scen
      end

      def build_cli
        scen = Scenario.new

        @options[:host].split(',').each do |host|
          backend = BackendBuilder.new(@options, host, nil).build
          node = Node.new(host, backend)
          node.hooks = HookBuilder.new(@options).build(['all'])
          node.add_operation(
            build_cli_command_operation(@options[:command], Rundock::Attribute::NodeAttribute.new, @options))
          scen.nodes.push(node)
        end

        scen
      end

      private

      def build_cli_command_operation(command, node_attributes, cli_options)
        node_attributes.errexit = !cli_options[:run_anyway]
        Rundock::OperationFactory.instance(:command).create(Array(command), node_attributes.list)
      end

      def build_operations(ope_type, ope_content, node_attributes, cli_options, recursive)
        cli_options = {} if cli_options.nil?

        if cli_options[:command] &&
           (ope_type == :command || ope_type == :task)
          Logger.debug(%("--command or -c" option is specified and ignore scenario file.))
          return
        end

        unless recursive
          # apply cli options
          if !cli_options.key?(:run_anyway)
            node_attributes.errexit = true
          else
            node_attributes.errexit = !cli_options[:run_anyway]
          end
          node_attributes.dry_run = (cli_options && cli_options[:dry_run]) ? true : false
        end

        # override by scenario
        node_attributes.define_attr(ope_type, ope_content)
        Rundock::OperationFactory.instance(ope_type).create(Array(ope_content), node_attributes.list)
      end
    end
  end
end
