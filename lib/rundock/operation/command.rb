module Rundock
  module Operation
    class Command < Base
      def run(backend, attributes = {})
        @instruction.each do |i|
          if i.is_a?(Hash)
            attributes.merge!(i)
            next
          end

          backend.run_commands(i, attributes)
        end
      end
    end
  end
end
