require 'serverspec'
require 'net/ssh'

if ENV['TARGET_HOST'] != 'localhost'

  set :backend, :ssh
  host = ENV['TARGET_HOST']

  options = Net::SSH::Config.for(host, ["#{ENV['HOME']}/.ssh/config_rundock_spec_#{ENV['TARGET_HOST']}"])

  options[:user] ||= Etc.getlogin

  set :host,        options[:host_name] || host
  set :ssh_options, options
  set :request_pty, true
  set :disable_sudo, true
else
  set :backend, :exec
end
