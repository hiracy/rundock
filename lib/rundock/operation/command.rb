module Rundock
  module Operation
    class Command < Base
      def run(backend, attributes = {})
        @instruction.each do |i|
          backend.run_commands(i, attributes)
        end
      end
    end
  end
end
