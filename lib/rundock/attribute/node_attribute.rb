module Rundock
  module Attribute
    class NodeAttribute < Base
      attr_accessor :nodename
      attr_accessor :nodeinfo
      attr_accessor :task_info
      attr_accessor :errexit
      attr_accessor :cwd
      attr_accessor :sudo
      attr_accessor :dry_run
      attr_accessor :hooks

      AVAIL_TAKE_OVERS = [
        :task_info,
        :errexit,
        :cwd,
        :sudo,
        :dry_run
      ]

      def init_except_take_over_state
        list.each do |k, _v|
          define_attr(k, nil) unless AVAIL_TAKE_OVERS.include?(k)
        end
      end
    end
  end
end
