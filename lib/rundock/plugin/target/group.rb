require 'rundock/target/base'

module Rundock
  module Target
    class Group < Base
      def create_nodes(target_info = {}, options = {})
        targets = @contents[:targets]

        nodes = []

        targets.each do |n|
          backend_builder = Rundock::Builder::BackendBuilder.new(options, n, target_info)
          backend = backend_builder.build
          @parsed_options[n.to_sym] = backend_builder.parsed_options
          nodes << Node.new(n, backend)
        end

        [nodes, @parsed_options]
      end
    end
  end
end
