require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_cwd_scenario') do
  it { should be_file }
  its(:content) { should match(/^\/var\/tmp\/cwd_scenario_test/) }
end
