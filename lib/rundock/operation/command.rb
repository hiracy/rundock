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

      private

      def assign_args(cmd, args)
        return cmd unless args
        cmd.gsub(/\$#/, args.length.to_s)
           .gsub(/\$@/, args.join(' '))
           .gsub(/\$[1-9]*/) { |arg_n| args[arg_n.chars[1..-1].join.to_i - 1] }
      end
    end
  end
end
