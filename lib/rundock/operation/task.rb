module Rundock
  module Operation
    class Task < Base
      def run(backend, attributes = {})
        @instruction.each do |i|
          previous_args = attributes[:task_args]
          task_set = i.split(' ')
          task_name = task_set.first

          if task_set.length > 1
            attributes[:task_args] = task_set.slice(1..-1).map do |arg|
              assign_args(arg, previous_args)
            end
          end

          unless attributes[:task_info].key?(task_name.to_sym)
            Logger.warn("task not found and ignored: #{task_name}")
            next
          end

          scenario = Rundock::Builder::ScenarioBuilder.new(nil, nil).build_task(
            attributes[:task_info][task_name.to_sym], backend, Rundock::Attribute::NodeAttribute.new(attributes)
          )

          logging(i, 'info')
          Logger.formatter.rec_lock

          scenario.run
          Logger.formatter.rec_unlock
        end
      end
    end
  end
end
