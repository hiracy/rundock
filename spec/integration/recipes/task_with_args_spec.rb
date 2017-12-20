require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_task_with_args_scenario/hello_rundock_from_task_with_args_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from task with args Scenario. task_with_args two 2/) }
end

describe file("/var/tmp/hello_rundock_from_#{ENV['USER']}_scenario") do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from task with args Scenario. task_with_args two 2/) }
end
