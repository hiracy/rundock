module Rundock
  module Attribute
    class NodeAttribute < Base
      attr_accessor :nodename
      attr_accessor :nodeinfo
      attr_accessor :task_info
      attr_accessor :errexit
      attr_accessor :enable_hooks

      AVAIL_TAKE_OVERS = [
        :task_info,
        :errexit
      ]

      def finalize_node
        list.each do |k, _v|
          define_attr(k, nil) unless AVAIL_TAKE_OVERS.include?(k)
        end
      end
    end
  end
end
