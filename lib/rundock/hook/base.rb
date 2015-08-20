module Rundock
  module Hook
    class Base
      HookNotImplementedError = Class.new(NotImplementedError)

      attr_reader :name
      attr_reader :contents

      def initialize(name, contents = {})
        @name = name
        @contents = contents
      end

      def hook(log_buffer = [], node_info = {})
        raise HookNotImplementedError
      end
    end
  end
end
