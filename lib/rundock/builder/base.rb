module Rundock
  module Builder
    class Base
      BuilderNotImplementedError = Class.new(NotImplementedError)

      def initialize(options)
        @options = options
      end

      def build
        raise BuilderNotImplementedError
      end
    end
  end
end
