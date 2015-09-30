require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_sudo_scenario') do
  it { should be_file }
  it { should be_owned_by 'root' }
end

describe file('/var/tmp/hello_rundock_from_no_sudo_scenario') do
  it { should be_file }
  it { should_not be_owned_by 'root' }
end
