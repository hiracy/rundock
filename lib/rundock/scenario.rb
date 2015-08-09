module Rundock
  class Scenario
    attr_accessor :nodes
    attr_accessor :node_info
    attr_accessor :tasks

    def initialize
      @nodes = []
    end

    def run
      @nodes.each(&:run)
    end

    def complete
      @nodes.each { |n| n.complete(self) }
      self
    end
  end
end
