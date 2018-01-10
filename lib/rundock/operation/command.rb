module Rundock
  module Operation
    class Command < Base
      def run(backend, attributes = {})
        @instruction.each do |i|
          if i.is_a?(Hash)
            attributes.merge!(i)
            next
          end

          logging(i, 'info')

          backend.run_commands(
            assign_args(i, attributes[:task_args]), attributes
          )
        end
      end
    end
  end
end
