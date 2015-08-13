require 'rundock/operation/base'

module Rundock
  module Operation
    # You can use this as following scenario.yml for example.
    #
    # - node: localhost
    #  deploy:
    #    - src: /tmp/deploy_from_local_file
    #      dst: /tmp/deploy_dest_local_file
    #    - src: /tmp/deploy_from_local_dir
    #      dst: /tmp/deploy_dest_local_dir
    # - node: anyhost-01
    #  deploy:
    #    - src: /tmp/deploy_from_local_file
    #      dst: /tmp/deploy_dest_remote_file
    #    - src: /tmp/deploy_from_local_dir
    #      dst: /tmp/deploy_dest_remote_dir
    # ---
    # anyhost-01:
    #   host: 192.168.1.11
    #   ssh_opts:
    #     port: 22
    #     user: anyuser
    #     key:  ~/.ssh/id_rsa
    # ---
    class Deploy < Base
      def run(backend, attributes)
        options = attributes[:deploy]

        options.each do |path|
          Logger.error('src: options not found.') if !path[:src] || path[:src].blank?
          Logger.error('dst: options not found.') if !path[:dst] || path[:dst].blank?
          Logger.info("deploy localhost:#{path[:src]} remote:#{attributes[:nodeinfo][:host]}:#{path[:dst]}")
          backend.send_file(path[:src], path[:dst])
        end
      end
    end
  end
end
