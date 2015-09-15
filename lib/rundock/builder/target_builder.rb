module Rundock
  module Builder
    class TargetBuilder < Base
      TargetNoSupportError = Class.new(NotImplementedError)
      TargetGroupNotFoundError = Class.new(StandardError)

      attr_accessor :parsed_node_options

      def build(target_name, target_info)
        # host type specified if target not found.
        if target_info.nil? ||
           !target_info.key?(target_name.to_sym) ||
           !target_info[target_name.to_sym].key?(:target_type) ||
           target_info[target_name.to_sym][:target_type] == 'host'

          backend_builder = BackendBuilder.new(@options, target_name, target_info)
          backend = backend_builder.build
          @parsed_node_options = { target_name.to_sym => backend_builder.parsed_options }

          return Node.new(target_name, backend)
        else
          raise TargetNoSupportError
        end
      end

      def build_group(target_group_name, target_info)
        if !target_info.nil? &&
           target_info.key?(target_group_name.to_sym) &&
           target_info[target_group_name.to_sym][:target_type] == 'group' &&
           target_info[target_group_name.to_sym].key?(:targets) &&
           target_info[target_group_name.to_sym][:targets].is_a?(Array)

          targets = target_info[target_group_name.to_sym][:targets]
          nodes = []
          @parsed_node_options = {}

          targets.each do |n|
            backend_builder = BackendBuilder.new(@options, n, target_info)
            backend = backend_builder.build

            @parsed_node_options[n.to_sym] = backend_builder.parsed_options
            nodes << Node.new(n, backend)
          end

          nodes
        else
          raise TargetGroupNotFoundError
        end
      end
    end
  end
end
