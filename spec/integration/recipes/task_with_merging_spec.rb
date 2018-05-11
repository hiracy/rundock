require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_task_with_merging/do_task_1') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from task with merging do task 1/) }
end

describe file('/var/tmp/hello_rundock_from_task_with_merging/do_task_2') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from task with merging do task 2/) }
end
