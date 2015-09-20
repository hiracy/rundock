require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_task_by_option_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from task by option Scenario./) }
end
