require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_file_hook_one_scenario') do
  it { should be_file }
  its(:content) { should match(/hookname:file_one /) }
  its(:content) { should match(/DEBUG/) }
end

describe file('/var/tmp/hello_rundock_from_file_hook_array_1_scenario') do
  it { should be_file }
  its(:content) { should match(/anyhost-01/) }
  its(:content) { should match(/hookname:file_array_1 /) }
  its(:content) { should match(/DEBUG/) }
end

describe file('/var/tmp/hello_rundock_from_file_hook_array_2_scenario') do
  it { should be_file }
  its(:content) { should match(/anyhost-01/) }
  its(:content) { should match(/hookname:file_array_2 /) }
  its(:content) { should match(/DEBUG/) }
end

describe file('/var/tmp/hello_rundock_from_file_hook_all_1_scenario') do
  it { should be_file }
  its(:content) { should match(/hookname:file_all_1 /) }
  its(:content) { should match(/DEBUG/) }
end

describe file('/var/tmp/hello_rundock_from_file_hook_all_2_scenario') do
  it { should be_file }
  its(:content) { should match(/hookname:file_all_2 /) }
  its(:content) { should match(/DEBUG/) }
end
