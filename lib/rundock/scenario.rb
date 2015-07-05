module Rundock
  class Scenario < Array
    def run
      self.each(&:run)
    end
  end
end
