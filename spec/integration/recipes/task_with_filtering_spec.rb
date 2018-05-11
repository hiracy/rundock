require 'spec_helper'

describe file('/var/tmp/hello_rundock_from_task_with_filtering/do_task_1') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from task with filtering do task 1/) }
end

describe file('/var/tmp/hello_rundock_from_task_with_filtering/do_task_2') do
  it { should be_file }
  its(:content) { should match(/Hello Rundock from task with filtering do task 2/) }
end

describe file('/var/tmp/hello_rundock_from_task_with_filtering/do_not_task_1') do
  it { should_not be_file }
end

describe file('/var/tmp/hello_rundock_from_task_with_filtering/do_not_task_2') do
  it { should_not be_file }
end
