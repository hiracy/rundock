require 'yaml'

module Rundock
  module Builder
    class TaskBuilder < Base
      DEFAULT_TASKS_FILE_PATH = './tasks.yml'

      def build(scenario_tasks)
        tasks = if scenario_tasks.nil?
                     {}
                   else
                     scenario_tasks
                   end
        return scenario_tasks unless @options[:tasks]
        return tasks if @options[:tasks].nil?

        task_files = @options[:tasks].split(',')

        task_files.each do |tk|
          tk.gsub!(/~/, Dir.home)

          if FileTest.exist?(tk)
            tasks.merge!(YAML.load_file(tk).deep_symbolize_keys)
            Logger.info("merged tasks file #{tk}")
          elsif FileTest.exist?(DEFAULT_TASKS_FILE_PATH)
            Logger.warn("tasks file is not found. use #{DEFAULT_TASKS_FILE_PATH}")
            tasks.merge!(YAML.load_file(DEFAULT_TASKS_FILE_PATH).deep_symbolize_keys)
          else
            Logger.warn("Task path is not available. (#{tk})")
          end
        end

        tasks
      end
    end
  end
end
