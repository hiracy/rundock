require 'yaml'

module Rundock
  module Builder
    class ScenarioBuilder < Base
      CommandArgNotFoundError = Class.new(StandardError)

      def initialize(options, scenario_file_data)
        super(options)
        @scenario_file = scenario_file_data
        @default_ssh_builder = DefaultSshBuilder.new(@options)
      end

      def build
        # parse default ssh file
        @options.merge!(@default_ssh_builder.build)

        # use host specified
        return build_scenario_with_cli if @options[:host]

        # use scenario file
        build_scenario_with_file
      end

      def build_task(tasks, backend, target_attributes)
        OperationBuilder.new(@options).build_task(tasks, backend, target_attributes)
      end

      private

      def build_scenario_with_cli
        raise CommandArgNotFoundError, %("--command or -c" option is not specified.) unless @options[:command]
        ope = OperationBuilder.new(@options)
        ope.build_cli
      end

      def build_scenario_with_file
        if @scenario_file

          type = [:main, :target_info, :tasks, :hooks]
          scenario_data = {}

          YAML.load_documents(@scenario_file).each_with_index do |data, idx|
            if idx == 0
              scenario_data[type[idx]] = data
            else
              scenario_data[type[idx]] = data.deep_symbolize_keys unless data.nil?
            end
          end
        end

        ope = OperationBuilder.new(@options)
        ope.build_first(
          scenario_data[:main],
          @options[:command] ? scenario_data[:target_info] : TargetGroupBuilder.new(@options).build(scenario_data[:target_info]),
          TaskBuilder.new(@options).build(scenario_data[:tasks]),
          scenario_data[:hooks])
      end
    end
  end
end
