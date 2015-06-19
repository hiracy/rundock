require 'serverspec'
require 'net/ssh'

if ENV['TARGET_HOST'] !~ /localhost|127\.0\.0\.1/

  set :backend, :ssh
  
  if ENV['ASK_SUDO_PASSWORD']
    begin
      require 'highline/import'
    rescue LoadError
      fail "highline is not available. Try installing it."
    end
    set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
  else
    set :sudo_password, ENV['SUDO_PASSWORD']
  end
  
  host = ENV['TARGET_HOST']
  
  options = Net::SSH::Config.for(host, ["~/.ssh/config_rundock_spec_#{host}"])
  
  options[:user] ||= Etc.getlogin
  
  set :host,        options[:host_name] || host
  set :ssh_options, options
else
  set :backend, :exec
end
