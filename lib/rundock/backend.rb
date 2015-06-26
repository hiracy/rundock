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
      attr_reader :options
      attr_reader :backend

      def initialize(type, options)
        @options = parse(options)
        @backend = create_specinfra_backend
      end

      def run_command(cmd , options = {})

        command = cmd.strip
        command = "cd #{Shellwords.escape(options[:cwd])} && #{command}" if options[:cwd]
        command = "sudo -H -u #{Shellwords.escape(user)} -- /bin/sh -c #{command}" if options[:user]

        Logger.debug(%Q{Start executing: "#{command}"})

        result = @backend.run_command(command)
        exit_status = result.exit_status

        Logger.formatter.indent do
          Logger.error("#{result.stderr}") unless result.stderr.blank?
          Logger.info("#{result.stdout.strip}") unless result.stdout.strip.blank?
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

        if options['ssh_config'] && File.exists?(options['ssh_config'])
          ssh_opts = Net::SSH::Config.for(options['host'], files=[options['ssh_config']])
        else
          ssh_opts = Net::SSH::Config.for(options['host'])
        end

        ssh_opts[:host_name] = options['host']
        ssh_opts[:user] = options['user']
        ssh_opts[:keys] = options['keys']
        ssh_opts[:keys] = Array(options['key']) if (!ssh_opts[:keys] && options['key'])
        ssh_opts[:port] = options['port']

        if options['ask_password']
          print "password: "
          passwd = STDIN.noecho(&:gets).strip
          print "\n"
          ssh_opts[:password] = passwd
        end

        ssh_opts.merge!(filter_net_ssh_options(options))

        Logger.debug(%Q{Net::SSH Options: "#{ssh_opts}"})

        ssh_opts
      end

      def filter_net_ssh_options(options)

        opts = {}
        options.each do |k,v|
          if Net::SSH::VALID_OPTIONS.include?(k.to_sym)
            opts[k.to_sym] = v
          end
        end

        opts
      end

      def create_specinfra_backend
        Specinfra::Backend::Ssh.new(
          request_pty: true,
          host: @options[:host_name],
          disable_sudo: !@options[:sudo],
          ssh_options: @options,
        )
      end
    end
  end
end
