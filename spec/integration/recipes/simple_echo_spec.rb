require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from Scenario./) }
end
