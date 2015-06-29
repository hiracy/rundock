require "bundler/gem_tasks"
require 'rspec/core/rake_task'

run_commands = [
  "rm -f /var/tmp/hello_rundock; echo \'Hello Rundock.\' > /var/tmp/hello_rundock"
]

run_scenarios = [
  'use_default_ssh_scenario',
  'simple_echo_scenario'
]

def setup_docker(platform, timeout, interval)
  Bundler.with_clean_env do
    system "./spec/integration/platformes/#{platform}/setup.sh &"
    found = false
    (timeout / interval).times do
      system "sudo docker ps | grep rundock"
      if $?.to_i == 0
        found = true
        break
      end
      sleep interval
    end
    raise "Docker Error." unless found
  end
end

def do_rundock_ssh(commands, platform, remote)
  unless remote
    commands.each do |cmd|
      system "bundle exec exe/rundock ssh -c \"#{cmd}\" -h localhost -l debug"
    end
  else
    commands.each do |cmd|
      system "bundle exec exe/rundock ssh -c \"#{cmd}\" -h 127.0.0.1 -p 22222 -u tester -i #{ENV['HOME']}/.ssh/id_rsa_rundock_spec_#{platform}_tmp -l debug"
    end
  end
end

def do_rundock_scenarios(scenarios, platform)
  scenarios.each do |scenario|
    default_ssh_opt = ''
    if scenario =~ /use_default_ssh/
      default_ssh_opt = " -d #{ENV['HOME']}/.rundock/#{platform}/integration_default_ssh.yml"
    end

    system "bundle exec exe/rundock do -s #{ENV['HOME']}/.rundock/#{platform}/scenarios/#{scenario}.yml#{default_ssh_opt} -l debug"
  end
end

desc "Cleaning environments"

task :clean do
  Bundler.with_clean_env do
    Dir.glob('./spec/integration/platformes/*').each do |platform|
      system "#{platform}/setup.sh --clean"
    end
  end
end

desc 'Run all tests.'
task :spec  => 'spec:integration:all'

namespace :spec do

  desc 'Run all tests for localhost.'
  task :local => 'integration:localhost:all'

  namespace :integration do

    targets = []
    Dir.glob('./spec/integration/platformes/*').each do |result|
      targets << File.basename(result)
    end
    targets << 'localhost'

    task :all => targets

    targets.each do |target|

      namespace target.to_sym do
        desc "Run rundock and serverspec tests for #{target}"

        unless target == 'localhost'
          task :all => [:docker, :rundock, :serverspec]
        else
          task :all => [:rundock, :serverspec]
        end
  
        unless target == 'localhost'
          desc "Setup Docker for #{target}"
          task :docker do
            # timeout 3 minutes and wait interval 10 seconds
            setup_docker(platform, 180, 10)
          end
        end
  
        desc "Run rundock for #{target}"

        task :rundock do
          Bundler.with_clean_env do
            do_rundock_ssh(run_commands, target, target != 'localhost')
            do_rundock_scenarios(run_scenarios, target) if target != 'localhost'
          end
        end
  
        desc "Run serverspec tests for #{target}"

        RSpec::Core::RakeTask.new(:serverspec) do |t|
          ENV['TARGET_HOST'] = target
          t.ruby_opts = '-I ./spec/integration'
          t.pattern = "./spec/integration/recipes/*_spec.rb"
        end
      end
    end
  end
end
