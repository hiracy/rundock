require 'highline'
require 'yaml'

module Rundock
  class Configure
    CONFIGURE_TYPE = %i[ssh]
    CONFIGURE_SSH_OPTIONS = %i[port user keys passphrase ssh_config]
    CONFIGURE_SSH_OPTIONS_QUESTION = [
      'ssh port',
      'user name',
      'private key path',
      'private key passphrase',
      'ssh config file path'
    ]

    class << self
      def start(options)
        Logger.debug 'Starting Configure:'

        configure = self.new(options)
        CONFIGURE_TYPE.each do |type|
          configure.send(type) if options[type]
        end
      end
    end

    def initialize(options)
      @options = options
    end

    def ssh
      cli = HighLine.new
      ssh_opts = { paranoid: false }

      CONFIGURE_SSH_OPTIONS.each_with_index do |opt, i|
        ans = if opt == :port
                cli.ask("#{CONFIGURE_SSH_OPTIONS_QUESTION[i]}:", Integer) { |q| q.in = 0..65535 }
              elsif opt == :user
                cli.ask("#{CONFIGURE_SSH_OPTIONS_QUESTION[i]}:") { |q| q.default = ENV['USER'] }
              elsif opt == :keys
                [cli.ask("#{CONFIGURE_SSH_OPTIONS_QUESTION[i]}:") { |q| q.default = '~/.ssh/id_rsa' }]
              elsif opt == :passphrase
                cli.ask("#{CONFIGURE_SSH_OPTIONS_QUESTION[i]}:") { |q| q.echo = '*' }
              elsif opt == :ssh_config
                cli.ask("#{CONFIGURE_SSH_OPTIONS_QUESTION[i]}:") { |q| q.default = '~/.ssh/config' }
              else
                cli.ask("#{CONFIGURE_SSH_OPTIONS_QUESTION[i]}:")
              end

        ssh_opts[opt] = ans unless ans.blank?
      end

      YAML.dump(ssh_opts, File.open(@options[:ssh_config_path], 'w'))
    end
  end
end
