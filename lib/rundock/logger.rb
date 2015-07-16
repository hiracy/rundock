require 'rundock'
require 'logger'
require 'ansi/code'

module Rundock
  module Logger
    class Formatter
      attr_accessor :colored
      attr_accessor :indent_depth
      attr_accessor :color
      attr_accessor :show_header

      def initialize(*args)
        super
        @indent_depth = 0
      end

      def call(severity, datetime, progname, msg)

        if @show_header
          out = "[\%5s:] %s%s\n" % [severity, ' ' * 2 * indent_depth, msg2str(msg)]
        else
          out = "%s\n" % [msg2str(msg)]
        end

        if colored
          colorize(out, severity)
        else
          out
        end
      end

      def indent
        add_indent
        yield
      ensure
        reduce_indent
      end

      def add_indent
        @indent_depth += 1
      end

      def reduce_indent
        @indent_depth -= 1 if @indent_depth > 0
      end

      def color(code)
        prev_color = @color
        @color = code
        yield
      ensure
        @color = prev_color
      end

      private

      def msg2str(msg)
        case msg
        when ::String
          msg
        when ::Exception
          "#{msg.message} (#{msg.class})\n" << (msg.backtrace || []).join("\n")
        else
          msg.inspect
        end
      end

      def colorize(msg, severity)
        if @color
          col = @color
        else
          col = case severity
                when 'INFO'
                  :clear
                when 'WARN'
                  :yellow
                when 'ERROR'
                  :red
                else
                  :clear
                end
        end

        ANSI.public_send(col) { msg }
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
