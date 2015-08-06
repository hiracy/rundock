module Rundock
  module Builder
    class BackendBuilder < Base
      attr_accessor :parsed_options

      def initialize(options, nodename, node_info)
        super(options)
        @nodename = nodename
        @node_info = node_info
      end

      def build
        @parsed_options = build_options

        backend_type = parse_backend_type

        @parsed_options.merge!(@options)

        # update ssh options for node from node_info
        @parsed_options.merge!(@node_info[@nodename.to_sym][:ssh_opts])

        # delete trash ssh_options(node[host::ssh_options])
        @node_info[@nodename.to_sym].delete(:ssh_opts)

        # add any attributes for host from node_info
        @parsed_options.merge!(@node_info[@nodename.to_sym])

        Backend.create(backend_type, @parsed_options)
      end

      private

      def build_options
        opts = {}

        if !@node_info ||
           !@node_info[@nodename.to_sym]
          @node_info = { @nodename.to_sym => {} }
        end
        @node_info[@nodename.to_sym][:ssh_opts] = {} unless @node_info[@nodename.to_sym][:ssh_opts]

        # replace default ssh options if exists
        @options.keys.select { |o| o.to_s =~ /(\w+)_ssh_default$/ }.each do |oo|
          # no use default ssh options if local
          # set unless scenario file and cli options specified and not localhost
          next if localhost?
          opt = oo.to_s.gsub(/_ssh_default/, '').to_sym
          if !@node_info[@nodename.to_sym][:ssh_opts][opt] && !@options[opt]
            @node_info[@nodename.to_sym][:ssh_opts][opt] = @options[oo]
          end
        end

        # replace cli ssh options if exists
        %w(:user :key :port :ssh_config :ask_password :sudo).each { |o| @node_info[@nodename.to_sym][:ssh_opts][o] = @options[o] if @options[o] }

        opts[:host] = @nodename
        opts
      end

      def parse_backend_type
        if localhost? &&
           !@node_info[@nodename.to_sym][:ssh_opts][:port] &&
           !@node_info[@nodename.to_sym][:ssh_opts][:user] &&
           !@node_info[@nodename.to_sym][:ssh_opts][:ssh_config]
          backend_type = :local
        else
          backend_type = :ssh
        end

        backend_type
      end

      def localhost?
        @nodename =~ /localhost|127\.0\.0\.1/ ||
          @node_info[@nodename.to_sym][:host] =~ /localhost|127\.0\.0\.1/
      end
    end
  end
end
