require 'yaml'

module Rundock
  module Builder
    class TargetGroupBuilder < Base
      DEFAULT_TARGET_GROUP_FILE_PATH = './targetgroup.yml'

      def build(scenario_targets)
        targets = {} unless scenario_targets

        if @options[:targetgroup]
          if FileTest.exist?(@options[:targetgroup])
            targets.merge!(YAML.load_file(@options[:targetgroup]).deep_symbolize_keys)
            Logger.info("merged target file #{@options[:targetgroup]}")
          elsif FileTest.exist?(DEFAULT_TARGET_GROUP_FILE_PATH)
            Logger.warn("targetgroup file is not found. use #{DEFAULT_TARGET_GROUP_FILE_PATH}")
            targets.merge!(YAML.load_file(DEFAULT_TARGET_GROUP_FILE_PATH).deep_symbolize_keys)
          else
            Logger.warn("Targetgroup path is not available. (#{@options[:targetgroup]})")
          end
        else
          return scenario_targets
        end

        targets
      end
    end
  end
end
