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
      @operations ||= []
      @operations << ope
    end

    def run
      Logger.formatter.on_rec
      Logger.debug("run node: #{@name}")
      Logger.warn("no operation running: #{@name}") if @operations.blank?

      node_attributes = []

      @operations.each do |ope|
        Logger.debug("run operation: #{ope.class}")
        node_attributes << ope.attributes
        ope.attributes[:nodename] = @name
        ope.run(@backend, ope.attributes)
      end

      log_buffer = Logger.formatter.flush unless Logger.formatter.buffer.empty?

      @hooks.each do |h|
        Logger.debug("run hook: #{h.name}")
        h.hook(node_attributes, log_buffer)
      end

      Logger.formatter.off_rec
    end
  end
end
