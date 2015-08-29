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

      def hook(operation_attributes = [], log_buffer = [])
        raise HookNotImplementedError
      end
    end
  end
end
