require 'rundock'
require 'logger'
require 'ansi/code'

module Rundock
  module Logger
    class Formatter
      attr_accessor :colored
      attr_accessor :indent
      attr_accessor :color

      def initialize(*args)
        super
        @indent = 0
      end

      def call(severity, datetime, progname, msg)
        out = "[%5s:] %s%s\n" % [severity, ' ' * 2 * indent, msg2str(msg)]
        if colored
          colorize(out, severity)
        else
          out
        end
      end

      private
      def msg2str(msg)
        case msg
        when ::String
          msg
        when ::Exception
          "#{ msg.message } (#{ msg.class })\n" <<
          (msg.backtrace || []).join("\n")
        else
          msg.inspect
        end
      end

      def colorize(msg, severity)

        if @color
          col = @color
        else
          col = case severity
                       when "INFO"
                         :clear
                       when "WARN"
                         :yellow
                       when "ERROR"
                         :red
                       else
                         :clear
                       end
        end

        ANSI.public_send(col) {msg}
      end
    end

    class << self
      def logger
        @logger ||= create_logger
      end

      private

      def create_logger
        ::Logger.new($stdout).tap do |logger|
          logger.formatter = Formatter.new
        end
      end

      private

      def respond_to_missing?(method, include_private = false)
        logger.respond_to?(method)
      end

      def method_missing(method, *args, &block)
        logger.public_send(method, *args, &block)
      end
    end
  end
end
