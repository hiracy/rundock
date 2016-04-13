require 'yaml'

module Rundock
  module Builder
    class DefaultSshBuilder < Base
      PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH = "#{Gem::Specification.find_by_path('rundock').full_gem_path}/default_ssh.yml"

      def initialize(options)
        super(options)
      end

      def build
        opts = {}

        def_ssh_file = if @options[:default_ssh_opts] && FileTest.exist?(@options[:default_ssh_opts])
                         @options[:default_ssh_opts]
                       else
                         PRESET_SSH_OPTIONS_DEFAULT_FILE_PATH
                       end

        File.open(def_ssh_file) do |f|
          YAML.load_documents(f) do |y|
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
