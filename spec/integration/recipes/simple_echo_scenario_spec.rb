require 'spec_helper'

describe file('/var/tmp/hello_rundock') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock./) }
end
