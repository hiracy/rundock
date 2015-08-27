require 'rundock/operation/base'

module Rundock
  module Hook
    # You can use this sample as following yaml files for example.
    #
    # [hook.yml]
    # major_log:
    #   hook_type: file
    #   filepath: /var/log/rundock.log
    # minor_log:
    #   hook_type: file
    #   filepath: /tmp/rundock.log
    #
    # [scenario.yml]
    # - node: anyhost-01
    # command:
    #   - 'rm -f /tmp/aaa'
    # hook:
    #   - major_log
    #   - minor_log
    # - node: localhost
    # command:
    #   - 'echo aaa > /tmp/abc'
    # hook: all
    # ---
    # anyhost-01:
    #   host: 192.168.1.11
    #   ssh_opts:
    #     port: 22
    #     user: anyuser
    #     key:  ~/.ssh/id_rsa
    # ---
    class File < Base
      def hook(node_attributes, log_buffer)
        file = ::File.open(@contents[:filepath], 'w')
        file.puts("[hookname:#{@name} node:#{node_attributes[0][:nodename]}]")
        log_buffer.each do |log|
          file.puts("[\%5s:] %s%s\n" % [log.severity, ' ' * 2 * log.indent_depth, log.msg])
        end
        file.close
      end
    end
  end
end
