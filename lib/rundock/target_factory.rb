module Rundock
  class TargetFactory
    TargetNotSupportedError = Class.new(StandardError)

    def self.instance(type)
      self.new(type)
    end

    def initialize(type)
      @type = type
    end

    def create(name, attributes)
      klass = "Rundock::Target::#{@type.to_s.to_camel_case}"
      Logger.debug("initialize #{klass} target")
      raise TargetNotSupportedError unless Rundock::Target::Base.subclasses.map(&:to_s).include?(klass)

      obj = nil
      klass.split('::').map do |k|
        obj = if obj.nil?
                Kernel.const_get(k)
              else
                obj = obj.const_get(k)
              end
      end

      target = obj.new(name, attributes)
      target
    end
  end
end
