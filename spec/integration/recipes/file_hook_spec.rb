require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_file_hook_inner_one_scenario') do
  it { should be_file }
  its(:content) { should match(/hookname:file_hook_one /) }
  its(:content) { should match(/DEBUG/) }
end

describe file('/var/tmp/hello_rundock_from_file_hook_inner_two_scenario') do
  it { should be_file }
  its(:content) { should match(/hookname:file_hook_two /) }
  its(:content) { should match(/DEBUG/) }
end
