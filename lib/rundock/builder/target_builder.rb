module Rundock
  module Builder
    class TargetBuilder < Base
      TargetNoSupportError = Class.new(NotImplementedError)

      attr_accessor :parsed_options

      def build(target_name, target_info)
        # host type specified if target not found.
        if target_info.nil? ||
           !target_info.key?(target_name.to_sym) ||
           !target_info[target_name.to_sym].key?(:target_type) ||
           target_info[target_name.to_sym][:target_type] == 'host'

          backend_builder = BackendBuilder.new(@options, target_name, target_info)
          backend = backend_builder.build
          @parsed_options = backend_builder.parsed_options

          return Node.new(target_name, backend)
        else
          raise TargetNoSupportError
        end
      end
    end
  end
end
