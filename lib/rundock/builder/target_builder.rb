module Rundock
  module Builder
    class TargetBuilder < Base
      DEFAULT_TARGET_TYPE = 'host'

      def build(target_name, target_info)
        target_type = DEFAULT_TARGET_TYPE

        if target_info.nil? ||
           !target_info.key?(target_name.to_sym)
          target_info = { target_name.to_sym => {} }
          target_type = DEFAULT_TARGET_TYPE
        else
          target_type = if target_info[target_name.to_sym].key?(:target_type)
                          target_info[target_name.to_sym][:target_type]
                        else
                          DEFAULT_TARGET_TYPE
                        end
        end

        begin
          target = Rundock::TargetFactory.instance(target_type).create(target_name, target_info[target_name.to_sym])
        rescue Rundock::TargetFactory::TargetNotSupportedError
          Logger.error("target type not supported: #{target_type}")
        end

        target.create_nodes(target_info, @options)
      end
    end
  end
end
