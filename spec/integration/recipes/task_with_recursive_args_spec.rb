require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_task_with_recursive_a_b_1_2_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from task with recursive Scenario./) }
end

describe file('/var/tmp/hello_rundock_from_task_with_recursive_1_2_c_d_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from task with recursive Scenario./) }
end
