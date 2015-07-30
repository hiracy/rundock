require 'rundock/operation/base'

module Rundock
  module Operation
    # You can use this sample as following scenario.yml for example.
    #
    # - node: anyhost-01
    #   host_inventory:
    #     memory:
    #       total:
    # ---
    # anyhost-01:
    #   host: 192.168.1.11
    #   ssh_opts:
    #     port: 22
    #     user: anyuser
    #     key:  ~/.ssh/id_rsa
    # ---
    class HostInventory < Base
      def run(backend, attributes)
        attributes[:host_inventory].each do |hi|
          Logger.info(to_inventory(backend, hi))
        end
      end

      private

      def to_inventory(backend, inventory)
        ret = nil
        inventory.split('/').each do |s|
          if ret.nil?
            ret = backend.host_inventory[s.to_s]
            next
          end

          ret = ret[s.to_s]
        end

        ret
      end
    end
  end
end
