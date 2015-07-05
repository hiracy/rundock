module Rundock
  module Operation
    class Base
      OperationNotImplementedError = Class.new(NotImplementedError)

      attr_reader :instruction
      attr_reader :attributes

      def initialize(instruction, attributes)
        @instruction = instruction
        @attributes = attributes
        @attributes = {} unless attributes
      end

      def run(backend, attributes = {})
        raise OperationNotImplementedError
      end
    end
  end
end
