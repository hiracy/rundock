require 'rundock/operation/base'

module Rundock
  module Operation
    # You can use this sample as following scenario.yml for example.
    #
    # - node: anyhost-01
    # sample_operation:
    #   - cmd: 'ls ~'
    #     all: true
    # ---
    # anyhost-01:
    #   host: 192.168.1.11
    #   ssh_opts:
    #     port: 22
    #     user: anyuser
    #     key:  ~/.ssh/id_rsa
    # ---
    class SampleOperation < Base
      def run(backend, attributes)
        operation = attributes[:sample_operation][0]

        cmd = ''
        args_line = ''
        operation.each do |k, v|
          if k == :cmd
            cmd = v
            next
          end

          if v.is_a?(TrueClass)
            args_line << " --#{k}"
          elsif v.is_a?(String)
            args_line << " --#{k} #{v}"
          end
        end

        Logger.info("do #{cmd}#{args_line}")
        result = backend.run_command("#{cmd}#{args_line}")
        Logger.info(result.stdout)
      end
    end
  end
end
