module Rundock
  class OperationFactory
    OperationNotImplementedError = Class.new(NotImplementedError)

    def self.instance(type)
      self.new(type)
    end

    def initialize(type)
      @type = type
    end

    def create(instruction, attributes)
      klass = "Rundock::Operation::#{@type.to_s.to_camel_case}"
      raise OperationNotImplementedError unless Rundock::Operation::Base.subclasses.map { |c| c.to_s }.include?(klass)
      operation = Kernel.const_get(klass).new(instruction, attributes)
      operation
    end
  end
end
