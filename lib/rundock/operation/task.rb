module Rundock
  module Operation
    class Task < Base
      def run(backend, attributes = {})
        @instruction.each do |i|
          unless attributes[:task].key?(i)
            Logger.warn("task not found and ignored: #{i}")
            next
          end

          backend.run_commands(attributes[:task][i], attributes)
        end
      end
    end
  end
end
