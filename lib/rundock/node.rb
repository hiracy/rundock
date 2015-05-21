require 'rundock'

module Rundock
  class Node < Array

    attr_reader :host
    attr_reader :backend

    def initialize(host, backend)
      @host = host
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
