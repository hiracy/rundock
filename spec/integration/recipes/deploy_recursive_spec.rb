require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_deploy_dst_file_a_b_c_d_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from deploy recursive Scenario./) }
end
