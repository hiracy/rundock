module Rundock
  module Builder
    class OperationBuilder < Base
      def build_first(scenario, targets, tasks, hooks)
        parsing_node_attribute = Rundock::Attribute::NodeAttribute.new(task_info: {})
        scen = Scenario.new
        scen.tasks = tasks

        scenario.each do |sn|
          nodes = []
          operations = []
          hook_contents = []

          sn.deep_symbolize_keys.each do |sk, sv|
            if %i[target target_group].include?(sk)
              target_builder = TargetBuilder.new(@options)
              nodes, target_options = target_builder.build(sv, targets)
              nodes.each do |n|
                if n.is_a?(Node)
                  parsing_node_attribute = build_node_attribute(scen, n.name, parsing_node_attribute, tasks, target_options[n.name.to_sym])
                  operations = Array(build_cli_command_operation(@options[:command], parsing_node_attribute, @options)) if @options[:command]
                end
              end
            elsif sk == :hook
              hooks_builder = HookBuilder.new(@options)
              hook_contents = hooks_builder.build(Array(sv), hooks)
              parsing_node_attribute.hooks = hooks_builder.enable_hooks
            else
              ope = build_operations(sk, Array(sv), parsing_node_attribute, @options, false)
              operations << ope if ope
            end
          end

          nodes.each do |n|
            operations.each do |o|
              n.add_operation(o)
            end

            n.hooks = hook_contents
          end

          scen.nodes.concat(nodes)
        end

        scen
      end

      def build_task(tasks, backend, node_attribute)
        node = Node.new(node_attribute.nodename, backend)
        scen = Scenario.new

        node_attribute.define_attr(:parrent_task_args, node_attribute.task_args) if node_attribute.respond_to?(:task_args)

        tasks.each do |k, v|
          ope = build_operations(k, Array(v), node_attribute, nil, true)
          node.add_operation(ope) if ope
        end

        scen.nodes.push(node) if node
        scen
      end

      def build_cli
        scen = Scenario.new

        hosts = @options[:host].split(',')
        hosts.each do |host|
          @options[:host] = host
          backend = BackendBuilder.new(@options, host, nil).build
          node = Node.new(host, backend)
          node.hooks = HookBuilder.new(@options).build(['all'], nil)
          node.add_operation(
            build_cli_command_operation(
              @options[:command],
              Rundock::Attribute::NodeAttribute.new,
              @options
            )
          )
          scen.nodes.push(node)
        end

        scen
      end

      private

      def build_node_attribute(scenario, nodename, node_attribute, tasks, parsed_options)
        node_attribute.init_except_take_over_state
        node_attribute.nodename = nodename
        tasks.each { |k, v| node_attribute.task_info[k] = v } if tasks

        scenario.node_info[nodename.to_sym] = node_attribute.nodeinfo = parsed_options

        node_attribute
      end

      def build_cli_command_operation(command, node_attributes, cli_options)
        node_attributes.nodename = @options[:host] unless node_attributes.nodename
        node_attributes.errexit = !cli_options[:run_anyway]
        node_attributes.dry_run = cli_options[:dry_run] ? true : false
        node_attributes.filtered_tasks = cli_options[:filtered_tasks] &&
                                         cli_options[:filtered_tasks].split(',')
        Rundock::OperationFactory.instance(:command).create(Array(command), node_attributes.list)
      end

      def build_operations(ope_type, ope_content, node_attributes, cli_options, recursive)
        cli_options = {} if cli_options.nil?

        if cli_options[:command] &&
           %i[command task].include?(ope_type)
          Logger.debug(%("--command or -c" option is specified and ignore scenario file.))
          return
        end

        unless recursive
          # apply cli options
          node_attributes.errexit = if !cli_options.key?(:run_anyway)
                                      true
                                    else
                                      !cli_options[:run_anyway]
                                    end
          node_attributes.dry_run = cli_options[:dry_run]
          node_attributes.filtered_tasks = cli_options[:filtered_tasks] &&
                                           cli_options[:filtered_tasks].split(',')
        end

        # override by scenario
        node_attributes.define_attr(ope_type, ope_content)
        Rundock::OperationFactory.instance(ope_type).create(Array(ope_content), node_attributes.list)
      end
    end
  end
end
