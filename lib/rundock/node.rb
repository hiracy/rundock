require 'rundock'

module Rundock
  class Node
    attr_reader :name
    attr_reader :operations
    attr_reader :backend
    attr_accessor :hooks

    def initialize(name, backend)
      @name = name
      @backend = backend
      @operations = []
      @hooks = []
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
      Logger.formatter.onrec = true
      Logger.debug("run node: #{@name}")
      if @operations.blank?
        Logger.warn("no operation running: #{@name}")
        return
      end

      nodeinfo = nil

      @operations.each do |ope|
        Logger.debug("run operation: #{ope.class}")
        nodeinfo = ope.attributes[:nodeinfo] if nodeinfo.nil?
        ope.run(@backend, ope.attributes)
      end

      log_buffer = Logger.formatter.flush unless Logger.formatter.buffer.empty?

      @hooks.each do |h|
        Logger.debug("run hook: #{h.name}")
        h.hook(log_buffer, nodeinfo)
      end

      Logger.formatter.onrec = false
    end
  end
end
