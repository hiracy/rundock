module Rundock
  class Scenario < Array
    def run
      self.each do |node|
        node.run
      end
    end
  end
end
