require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_deploy_erb_dst_file_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from deploy erb runrunrundock Scenario./) }
  its(:content) { should match(/Linux/) }
end
