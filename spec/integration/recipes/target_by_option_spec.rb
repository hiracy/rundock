require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_target_by_option_scenario') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from target by option Scenario./) }
end
