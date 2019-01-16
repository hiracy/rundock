require 'yaml'

module Rundock
  module Builder
    class DefaultSshBuilder < Base
      RUNDOCK_PACKAGE_PATH = Gem::Specification.find_by_path('rundock')
      PRESET_SSH_OPTIONS_DEFAULT_ROOT = RUNDOCK_PACKAGE_PATH.nil? ? '.' : RUNDOCK_PACKAGE_PATH.full_gem_path
      PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH = "#{PRESET_SSH_OPTIONS_DEFAULT_ROOT}/default_ssh.yml"
      HOME_SSH_OPTIONS_DEFAULT_FILE_PATH = "#{Dir.home}/default_ssh.yml"

      def initialize(options)
        super(options)
      end

      def build
        opts = {}

        def_ssh_file = if @options[:default_ssh_opts] && FileTest.exist?(@options[:default_ssh_opts])
                         @options[:default_ssh_opts]
                       elsif FileTest.exist?(HOME_SSH_OPTIONS_DEFAULT_FILE_PATH)
                         HOME_SSH_OPTIONS_DEFAULT_FILE_PATH
                       else
                         PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH
                       end

        File.open(def_ssh_file) do |f|
          YAML.load_stream(f) do |y|
            y.each do |k, v|
              opts["#{k}_ssh_default".to_sym] = v
            end
          end
        end

        opts
      end
    end
  end
end
