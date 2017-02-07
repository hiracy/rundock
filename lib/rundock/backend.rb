require 'rundock'
require 'singleton'
require 'specinfra/core'
require 'io/console'
require 'net/ssh'
require 'net/ssh/proxy/command'

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

      def send_file(from, to)
        system("test -d #{from}")
        recursive = $?.to_i == 0

        if !recursive
          @backend.send_file(from, to)
        else
          @backend.send_directory(from, to)
        end
      end

      def specinfra_run_command(command)
        @backend.run_command(command)
      end

      private

      def run_command(cmd, exec_options = {})
        command = cmd.strip
        command = "sudo #{command.gsub(/^sudo +/, '')}" if exec_options[:sudo]
        command = "cd #{Shellwords.escape(exec_options[:cwd])} && #{command}" if exec_options[:cwd]
        command = "sudo -H -u #{Shellwords.escape(user)} -- /bin/sh -c #{command}" if exec_options[:user]

        Logger.debug(%(Start executing: "#{command}"))

        return nil if exec_options[:dry_run]

        result = @backend.run_command(command)
        exit_status = result.exit_status

        Logger.formatter.indent do
          Logger.debug("cwd: #{exec_options[:cwd]}") if exec_options[:cwd]
          Logger.debug("sudo: #{exec_options[:sudo]}") if exec_options[:sudo]
          Logger.error(result.stderr.strip) unless result.stderr.strip.blank?
          Logger.info(result.stdout.strip) unless result.stdout.strip.blank?
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

      def host_inventory
        @backend.host_inventory
      end

      def method_missing(method, *args)
        @backend.send(method, *args)
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
        ssh_opts = if options[:ssh_config] && FileTest.exists?(options[:ssh_config])
                     Net::SSH::Config.for(options[:host], [options[:ssh_config]])
                   else
                     Net::SSH::Config.for(options[:host])
                   end

        # priority = (cli options > scenario target information section > ssh config)
        ssh_opts[:host_name] = options[:host] unless ssh_opts[:host_name]
        ssh_opts[:keys] = Array(options[:key]) if options[:key]
        ssh_opts[:password] = parse_password_from_stdin if options[:ask_password]
        ssh_opts.merge!(filter_net_ssh_options(options))
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
