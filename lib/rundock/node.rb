require 'rundock'

module Rundock
  class Node

    attr_reader :name
    attr_reader :operations
    attr_reader :backend

    def initialize(name, operations, backend)
      @name = name
      @operations = operations
      @backend = backend
    end

    def run
      Logger.debug("run name: #{@name}")
      @operations.each do |ope|
        ope.run(@backend)
      end
    end
  end
end
