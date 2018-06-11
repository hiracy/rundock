require 'rundock/target/base'

module Rundock
  module Target
    class Host < Base
      def create_nodes(target_info = {}, options = {})
        backend_builder = Rundock::Builder::BackendBuilder.new(options, @name, target_info)
        backend = backend_builder.build
        @parsed_options = { @name.to_sym => backend_builder.parsed_options }
        [Array(Node.new(@name, backend)), @parsed_options]
      end
    end
  end
end
