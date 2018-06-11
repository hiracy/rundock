module Rundock
  module Target
    class Base
      TargetNotImplementedError = Class.new(NotImplementedError)

      attr_reader :name
      attr_reader :contents
      attr_reader :parsed_options

      def initialize(name, contents = {})
        @name = name
        @contents = contents
        @parsed_options = {}
      end

      def create_nodes(target_info = {}, options = {})
        raise TargetNotImplementedError
      end
    end
  end
end
