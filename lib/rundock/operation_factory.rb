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
      Logger.debug("initialize #{klass} operation")
      raise OperationNotImplementedError unless Rundock::Operation::Base.subclasses.map(&:to_s).include?(klass)

      obj = nil
      klass.split('::').map do |k|
        if obj.nil?
          obj = Kernel.const_get(k)
        else
          obj = obj.const_get(k)
        end
      end

      operation = obj.new(instruction, attributes)
      operation
    end
  end
end
