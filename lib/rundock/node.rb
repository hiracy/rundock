require 'rundock'

module Rundock
  class Node
    attr_reader :name
    attr_reader :operations
    attr_reader :backend

    def initialize(name, backend)
      @name = name
      @backend = backend
      @operations = []
    end

    def add_operation(ope)
      @operations = [] unless @operations
      @operations << ope
    end

    def complete(scenario)
      @operations.each do |ope|
        ope.attributes[:nodeinfo].merge!(scenario.node_info)
      end
    end

    def run
      Logger.debug("run node: #{@name}")
      if @operations.blank?
        Logger.warn("no operation running: #{@name}")
        return
      end
      @operations.each do |ope|
        Logger.debug("run operation: #{ope.class}")
        ope.run(@backend, ope.attributes)
      end
    end
  end
end
