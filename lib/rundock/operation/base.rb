module Rundock
  module Operation
    class Base
      OperationNotImplementedError = Class.new(NotImplementedError)

      attr_reader :instruction
      attr_reader :attributes

      def initialize(instruction, attributes)
        @instruction = instruction
        @attributes = attributes
        @attributes = {} unless attributes
      end

      def run(backend, attributes = {})
        raise OperationNotImplementedError
      end

      def logging(message, severity)
        h_host = @attributes[:nodename].just(' ', 15)
        h_ope = "start #{self.class.to_s.split('::').last.downcase}:"
        Logger.send(severity.to_sym, "#{h_host} #{h_ope} #{message}")
      end

      def assign_args(cmd, args)
        return cmd unless args
        cmd.gsub(/\$#/, args.length.to_s)
           .gsub(/\$@/, args.join(' '))
           .gsub(/\$[1-9]/) { |arg_n| args[arg_n.chars[1..-1].join.to_i - 1] }
           .gsub(/(\$\{)(\w+)(\})/) { ENV[Regexp.last_match(2)] }
      end
    end
  end
end
