require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_deploy_dst_file_arg_2_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from deploy args Scenario./) }
end

describe file('/var/tmp/hello_rundock_from_deploy_dst_file_arg_binding_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from deploy args runrunrundock Scenario./) }
end
