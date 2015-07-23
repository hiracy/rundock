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
        self.const_get(type.capitalize).new(options)
      end
    end

    class Base
      attr_reader :options
      attr_reader :backend

      def initialize(options)
        @options = parse(options)
        @backend = create_specinfra_backend
      end

      def run_commands(cmd, exec_options = {})
        Array(cmd).each do |c|
          run_command(c, exec_options)
        end
      end

      private

      def run_command(cmd, exec_options = {})
        command = cmd.strip
        command = "cd #{Shellwords.escape(exec_options[:cwd])} && #{command}" if exec_options[:cwd]
        command = "sudo -H -u #{Shellwords.escape(user)} -- /bin/sh -c #{command}" if exec_options[:user]

        Logger.debug(%(Start executing: "#{command}"))

        result = @backend.run_command(command)
        exit_status = result.exit_status

        Logger.formatter.indent do
          Logger.error("#{result.stderr}") unless result.stderr.blank?
          Logger.info("#{result.stdout.strip}") unless result.stdout.strip.blank?
          Logger.debug("errexit: #{exec_options[:errexit]}")
          Logger.debug("exit status: #{exit_status}")
        end

        if exec_options[:errexit] && exit_status != 0
          raise CommandResultStatusError
        end

        result
      end

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
        Specinfra::Backend::Exec.new
      end
    end

    class Ssh < Base
      private

      def parse(options)
        if options[:ssh_config] && FileTest.exists?(options[:ssh_config])
          ssh_opts = Net::SSH::Config.for(options[:host], [options[:ssh_config]])
        else
          ssh_opts = Net::SSH::Config.for(options[:host])
        end

        ssh_opts.merge!(filter_net_ssh_options(options))
        # priority = node_attributes > cli options
        ssh_opts[:host_name] = options[:host]
        ssh_opts[:keys] = Array(options[:key]) if options[:key]
        ssh_opts[:password] = parse_password_from_stdin if options[:ask_password]
        ssh_opts[:proxy] = Kernel.eval(options[:proxy]) if options[:proxy]

        Logger.debug(%(Net::SSH Options: "#{ssh_opts}"))

        ssh_opts
      end

      def parse_password_from_stdin
        print 'password: '
        passwd = STDIN.noecho(&:gets).strip
        print "\n"
        passwd
      end

      def filter_net_ssh_options(options)
        opts = {}
        options.each do |k, v|
          opts[k] = v if Net::SSH::VALID_OPTIONS.include?(k)
        end

        opts
      end

      def create_specinfra_backend
        Specinfra::Backend::Ssh.new(
          request_pty: true,
          host: @options[:host_name],
          disable_sudo: !@options[:sudo],
          ssh_options: @options
        )
      end
    end
  end
end
