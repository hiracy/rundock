module Rundock
  module Operation
    class Task < Base
      def run(backend, attributes = {})
        @instruction.each do |i|
          unless attributes[:task_info].key?(i.to_sym)
            Logger.warn("task not found and ignored: #{i}")
            next
          end

          scenario = Rundock::Builder::ScenarioBuilder.new(nil, nil).build_task(
            attributes[:task_info][i.to_sym], backend, attributes)

          scenario.run
        end
      end
    end
  end
end
