require 'rundock/operation/base'
require 'erb'
require 'tempfile'
require 'ostruct'

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
    #    - src: /tmp/deploy_from_local_erb_bile
    #      dst: /tmp/deploy_dest_remote_file
    #      erb: true
    #      trim_mode: '-'
    #      binding:
    #        hostname:
    #          type: command
    #          value: 'hostname'
    #        memtotal:
    #          type: command
    #          value: "cat /proc/meminfo | grep 'MemTotal' | awk '{print $2}'"
    # ---
    # anyhost-01:
    #   host: 192.168.1.11
    #   ssh_opts:
    #     port: 22
    #     user: anyuser
    #     key:  ~/.ssh/id_rsa
    # ---
    class Deploy < Base
      DEFAULT_TRIM_MODE = '-'
      DEFAULT_BINDING_TYPE = 'command'

      def run(backend, attributes)
        options = attributes[:deploy]

        options.each do |opt|
          Logger.error('src: options not found.') if !opt.key?(:src) || opt[:src].blank?
          Logger.error('dst: options not found.') if !opt.key?(:dst) || opt[:dst].blank?

          is_erb = opt.key?(:erb) && opt[:erb]

          trim_mode = if opt.key?(:trim_mode)
                        opt[:trim_mode]
                      else
                        DEFAULT_TRIM_MODE
                      end

          erb_options = ''
          erb_options = " erb: true trim_mode: #{trim_mode}" if is_erb

          logging("deploy localhost: #{opt[:src]} remote:#{attributes[:nodeinfo][:host]}:#{opt[:dst]}#{erb_options}", 'info')
          Logger.debug("deploy erb binding: #{opt[:binding]}") if is_erb

          val_binding = if is_erb
                          extract_map(backend, opt[:binding])
                        else
                          {}
                        end

          if is_erb
            erb_content = conv_erb(opt[:src], trim_mode, val_binding)

            tempfile = Tempfile.new('', Dir.tmpdir)
            begin
              tempfile.write(erb_content)
              tempfile.rewind
              backend.send_file(tempfile.path, opt[:dst])
            ensure
              tempfile.close
            end
          else
            backend.send_file(opt[:src], opt[:dst])
          end
        end
      end

      private

      def conv_erb(src, trim_mode, mapping)
        srcfile = ::File.open(src, &:read)

        begin
          ERB.new(srcfile, nil, trim_mode).tap do |erb|
            erb.filename = src
          end.result(OpenStruct.new(mapping).instance_eval { binding })
        rescue => ex
          Logger.error("ERB Error: #{ex.message}")
        end
      end

      def extract_map(backend, binding)
        map = {}
        binding.each do |k, v|
          map[k] = backend.specinfra_run_command(v[:value]).stdout.strip if v.key?(:value)
        end

        map
      end
    end
  end
end
