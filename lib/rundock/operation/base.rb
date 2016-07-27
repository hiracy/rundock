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

      def logging(message, severity)
        h_host = @attributes[:nodename].just(' ', 15)
        h_ope = "start #{self.class.to_s.split('::').last.downcase}:"
        Logger.send(severity.to_sym, "#{h_host} #{h_ope} #{message}")
      end
    end
  end
end
