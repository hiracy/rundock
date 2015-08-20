module Rundock
  class HookFactory
    HookNotImplementedError = Class.new(NotImplementedError)

    def self.instance(type)
      self.new(type)
    end

    def initialize(type)
      @type = type
    end

    def create(name, attributes)
      klass = "Rundock::Hook::#{@type.to_s.to_camel_case}"
      Logger.debug("initialize #{klass} hook")
      raise HookNotImplementedError unless Rundock::Hook::Base.subclasses.map(&:to_s).include?(klass)

      obj = nil
      klass.split('::').map do |k|
        if obj.nil?
          obj = Kernel.const_get(k)
        else
          obj = obj.const_get(k)
        end
      end

      hook = obj.new(name, attributes)
      hook
    end
  end
end
