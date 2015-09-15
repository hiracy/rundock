require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_target_group_1_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from target group 1 Scenario./) }
end

describe file('/var/tmp/hello_rundock_from_target_group_2_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from target group 2 Scenario./) }
end
