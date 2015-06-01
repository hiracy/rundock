require 'rundock'

module Rundock
  class Node < Array

    attr_reader :name
    attr_reader :operations
    attr_reader :backend

    def initialize(name, operations, backend)
      @name = name
      @operations = operations
      @backend = backend
    end

    def tasks
      self.map do |t|
        case t
        when Task
          t
        end
      end
    end
  end
end
