require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_deploy_dst_file_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from deploy Scenario./) }
end

describe file('/var/tmp/hello_rundock_from_deploy_dst_dir_scenario') do
  it { should be_directory }
end
