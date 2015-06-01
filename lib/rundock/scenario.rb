module Rundock
  class Scenario < Array
    def run(options)
      self.each do |node|
        node.run
      end
    end
  end
end
