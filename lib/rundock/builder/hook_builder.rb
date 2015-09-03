require 'yaml'

module Rundock
  module Builder
    class HookBuilder < Base
      DEFAULT_HOOKS_FILE_PATH = './hooks.yml'
      HookStructureError = Class.new(NotImplementedError)

      attr_accessor :enable_hooks

      def initialize(options)
        super(options)
        @enable_hooks = {}
      end

      def build(enables, hook_attributes)
        if enables.blank?
          Logger.info('Empty hook is specified.')
          return []
        elsif hook_attributes.nil? && @options[:hooks]
          if FileTest.exist?(@options[:hooks])
            hooks_file = @options[:hooks]
            Logger.info("hooks file is #{hooks_file}")
          else
            Logger.warn("hooks file is not found. use #{DEFAULT_HOOKS_FILE_PATH}")
            hooks_file = DEFAULT_HOOKS_FILE_PATH
          end
        elsif hook_attributes.nil?
          Logger.warn("Hook source is not found. (enables:#{enables.join(',')})") unless enables.empty?
          return []
        end

        if hooks_file
          build_from_attributes(YAML.load_file(hooks_file).deep_symbolize_keys, enables)
        else
          build_from_attributes(hook_attributes, enables)
        end
      end

      def rebuild(node_attributes)
        hooks = []

        node_attributes.each do |k, v|
          hooks = Rundock::HookFactory.instance(v[:hook_type]).create(k.to_s, v)
        end

        hooks
      end

      private

      def build_from_attributes(attributes, enables)
        hooks = []

        allow_all = enables.include?('all')

        attributes.each do |k, v|
          raise HookStructureError unless v.is_a?(Hash)
          next if !allow_all && !enables.include?(k.to_s)
          @enable_hooks[k] = v
          hooks << Rundock::HookFactory.instance(v[:hook_type]).create(k.to_s, v)
        end

        Logger.warn('Empty hook is detected. Please verity hooks file and scenario file.') if hooks.empty?

        hooks
      end
    end
  end
end
