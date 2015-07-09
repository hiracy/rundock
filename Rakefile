require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

run_commands = [
  'rm -f /var/tmp/hello_rundock;' \
    'echo \'Hello Rundock.\' > /var/tmp/hello_rundock'
]

run_scenarios = %w(
  use_default_ssh_scenario
  simple_echo_scenario
)

def execute(command)
  puts "[EXECUTE:] #{command}"
  system command
end

def setup_docker(platform, timeout, interval)
  Bundler.with_clean_env do
    execute "./spec/integration/platforms/#{platform}/setup.sh &"
    found = false
    (timeout / interval).times do
      execute 'sudo docker ps | grep rundock'
      if $?.to_i == 0
        found = true
        break
      end
      sleep interval
    end
    raise 'Docker Error.' unless found
  end
end

def do_rundock_ssh(commands, platform)
  if platform == 'localhost'
    commands.each do |cmd|
      execute "bundle exec exe/rundock ssh -c \"#{cmd}\" -h localhost -l debug"
    end
  else
    commands.each do |cmd|
      execute 'bundle exec exe/rundock' \
        " ssh -c \"#{cmd}\" -h 127.0.0.1 -p 22222 -u tester" \
        " -i #{ENV['HOME']}/.ssh/id_rsa_rundock_spec_#{platform}_tmp -l debug"
    end
  end
end

def do_rundock_scenarios(scenarios, platform)
  if platform == 'localhost'
    base_dir = './spec/integration/platforms/localhost'
  else
    base_dir = "#{ENV['HOME']}/.rundock/#{platform}"
  end

  scenarios.each do |scenario|
    default_ssh_opt = ''
    if scenario =~ /use_default_ssh/ && platform != 'localhost'
      default_ssh_opt = " -d #{base_dir}/integration_default_ssh.yml"
    end

    execute 'bundle exec exe/rundock' \
       " do -s #{base_dir}/scenarios/#{scenario}.yml#{default_ssh_opt} -l debug"
  end
end

desc 'Cleaning environments'

task :clean do
  Bundler.with_clean_env do
    Dir.glob('./spec/integration/platforms/*').each do |platform|
      execute "#{platform}/setup.sh --clean"
    end
  end
end

desc 'execute rubocop'
task :rubocop do
  Bundler.with_clean_env do
    execute 'rubocop'
  end
end

desc 'Run all tests.'
task :spec => ['rubocop', 'spec:integration:all']

namespace :spec do
  desc 'Run all tests for localhost.'
  task :local => 'integration:localhost:all'

  namespace :integration do
    targets = ['localhost']
    Dir.glob('./spec/integration/platforms/*').each do |result|
      targets << File.basename(result)
    end

    desc 'Run all tests for all platforms.'
    task :all => targets.map { |t| "spec:integration:#{t}:all" }

    targets.each do |target|
      namespace target.to_sym do
        desc "Run rundock and serverspec tests for #{target}"

        if target != 'localhost'
          task :all => [:docker, :rundock, :serverspec]
        else
          task :all => [:rundock, :serverspec]
        end

        unless target == 'localhost'
          desc "Setup Docker for #{target}"
          task :docker do
            # timeout 3 minutes and wait interval 10 seconds
            setup_docker(target, 180, 10)
          end
        end

        desc "Run rundock for #{target}"

        task :rundock do
          Bundler.with_clean_env do
            do_rundock_ssh(run_commands, target)
            do_rundock_scenarios(run_scenarios, target)
          end
        end

        desc "Run serverspec tests for #{target}"

        RSpec::Core::RakeTask.new(:serverspec) do |t|
          ENV['TARGET_HOST'] = target
          t.ruby_opts = '-I ./spec/integration'
          t.pattern = './spec/integration/recipes/*_spec.rb'
        end
      end
    end
  end
end
