module Rundock
  module Operation
    class Task < Base
      def run(backend, attributes = {})
        @instruction.each do |i|
          if attributes.key?(i)
            Logger.warn("[WARN]task not found and ignored: #{i}")
            next
          end

          backend.run_command(attributes[i])
        end
      end
    end
  end
end