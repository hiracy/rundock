require 'rundock'
require 'singleton'
require 'specinfra/core'
require 'io/console'
require 'net/ssh'

Specinfra::Configuration.error_on_missing_backend_type = true

module Rundock
  module Backend
    CommandResultStatusError = Class.new(StandardError)

    class << self
      def create(type, options = {})
        self.const_get(type.capitalize).new(type, options)
      end
    end

    class Base
      def initialize(type, options)
        @options = parse(options)
        @backend = create_specinfra_backend
      end

      def run_command(cmd , options = {})
        command = "cd #{Shellwords.escape(cwd)} && #{cmd}" if options[:cwd]

        Logger.debug(%Q{Start executing: "#{command}"})

        result = @backend.run_command(command)
        exit_status = result.exit_status

        Logger.formatter.indent do

          Logger.error("[ERROR]#{result.stderr}") if result.stderr
          Logger.info("#{result.stdout}")
          Logger.debug("exit status: #{exit_status}")
        end

        if options[:no_continue_if_error] && exit_status != 0
          raise CommandResultStatucError
        end

        result
      end

      private

      def parse(options)
        raise NotImplementedError
      end

      def create_specinfra_backend
        raise NotImplementedError
      end
    end

    class Local < Base
      private

      def parse(options)
        options
      end

      def create_specinfra_backend
        Specinfra::Backend::Exec.new()
      end
    end

    class Ssh < Base
      private

      def parse(options)
        if ssh_opts[:ssh_config] && File.exists?(ssh_opts[:ssh_config])
          ssh_opts = Net::SSH::Config.for(options[:host], files=[ssh_opts[:ssh_config]])
        else
          ssh_opts = Net::SSH::Config.for(options[:host])
        end

        ssh_opts.merge!(options)

        ssh_opts[:user] = ssh_opts[:user] || Etc.getlogin
        ssh_opts[:keys] = ssh_opts[:keys] || '~/.ssh/id_rsa'
        ssh_opts[:port] = ssh_opts[:port] || 22

        if ssh_options[:ask_password]
          print "password: "
          passwd = STDIN.noecho(&:gets).strip
          print "\n"
          ssh_opts[:password] = passwd
        end
      end

      def create_specinfra_backend
        Specinfra::Backend::Ssh.new(
          request_pty: true,
          host: @options[:host],
          disable_sudo: !@options[:sudo],
          ssh_options: @options,
        )
      end
    end
  end
end
