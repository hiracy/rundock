module Rundock
  module Operation
    class Base
      attr_reader :type
      attr_reader :instruction

      def initialize(type, instruction)
        @type = type
        @instruction = instruction
      end
    end
  end
end
