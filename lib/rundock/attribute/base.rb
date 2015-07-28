module Rundock
  module Attribute
    class Base
      def initialize(attr = {})
        attr.each { |k, v| define_attr(k.to_sym, v) }
      end

      def self.attr_accessor(*vars)
        @attributes ||= []
        @attributes.concat(vars)
        super(*vars)
      end

      def self.list
        @attributes
      end

      def list
        self.class.list.each_with_object({}) do |a, result|
          result[a] = self.send(a)
        end
      end

      def define_attr(name, val)
        self.class.send(:attr_accessor, name)
        self.send("#{name}=", val)
      end
    end
  end
end
