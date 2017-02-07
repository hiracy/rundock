require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :default => [:spec]

run_commands = [
  'rm -f /var/tmp/hello_rundock;' \
    'echo \'Hello Rundock.\' > /var/tmp/hello_rundock'
]

def execute(command, clean_env, errexit)
  puts "[EXECUTE:] #{command}"

  if clean_env
    Bundler.with_clean_env do
      system command
    end
  else
    system command
  end
  raise 'Execute Error.' if $?.to_i != 0 && errexit
end

def setup_docker(platform, timeout, interval)
  execute("./spec/integration/platforms/#{platform}/setup.sh &", false, true)
  found = false
  (timeout / interval).times do
    system 'sudo docker ps | grep rundock'
    if $?.to_i == 0
      found = true
      break
    end
    sleep interval
  end
  raise 'Docker Error.' unless found
end

def do_rundock_ssh(commands, platform)
  base_dir = "#{ENV['HOME']}/.rundock/#{platform}"
  groups_files_pattern = ["#{base_dir}/groups/*.yml"]

  if platform == 'localhost'
    commands.each do |cmd|
      execute("bundle exec exe/rundock ssh -c \"#{cmd}\" -h localhost -l debug", true, true)
    end
  else
    commands.each do |cmd|
      execute('bundle exec exe/rundock' \
        " ssh -c \"#{cmd}\" -h 172.17.0.1 -p 22222 -u tester" \
        " -i #{ENV['HOME']}/.ssh/id_rsa_rundock_spec_#{platform}_tmp -l debug", true, true)
      Dir.glob(groups_files_pattern).each do |g|
        execute('bundle exec exe/rundock' \
          " ssh -c \"#{cmd}\" -g #{g} -p 22222 -u tester" \
          " -i #{ENV['HOME']}/.ssh/id_rsa_rundock_spec_#{platform}_tmp -l debug", true, true)
      end
    end
  end
end

def do_rundock_scenarios(platform)
  if platform == 'localhost'
    base_dir = './spec/integration/platforms/localhost'
    scenario_files_pattern = ['./spec/integration/platforms/localhost/scenarios/*.yml']
  else
    base_dir = "#{ENV['HOME']}/.rundock/#{platform}"
    scenario_files_pattern = ["#{base_dir}/scenarios/*.yml"]
  end

  Dir.glob(scenario_files_pattern).each do |scenario|
    default_ssh_opt = if scenario =~ /use_default_ssh/ && platform != 'localhost'
                        " -d #{base_dir}/integration_default_ssh.yml"
                      else
                        ''
                      end

    options = ''
    if scenario =~ %r{^*scenarios/(.*hooks_by_option)_scenario.yml$}
      options = " -k ./spec/integration/hooks/#{Regexp.last_match(1)}.yml"
    elsif scenario =~ %r{^*scenarios/(.*task_by_option)_scenario.yml$}
      options = " -t ./spec/integration/tasks/#{Regexp.last_match(1)}.yml"
    elsif scenario =~ %r{^*scenarios/(.*target_by_option)_scenario.yml$}
      options = " -g #{base_dir}/targets/#{Regexp.last_match(1)}.yml"
    end

    execute('bundle exec exe/rundock' \
       " do #{scenario}#{default_ssh_opt}#{options} -l debug", true, true)
  end
end

desc 'Cleaning environments'

task :clean do
  execute('rm -fr /var/tmp/hello_rundock*', false, false)
  Dir.glob('./spec/integration/platforms/*').each do |platform|
    next if platform =~ /localhost$/
    execute("#{platform}/setup.sh --clean", false, true)
  end
end

desc 'execute rubocop'
task :rubocop do
  execute('rubocop', false, true)
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
          do_rundock_ssh(run_commands, target)
          do_rundock_scenarios(target)
        end

        desc "Run serverspec tests for #{target}"

        RSpec::Core::RakeTask.new(:serverspec) do |t|
          ENV['TARGET_HOST'] = target
          t.ruby_opts = '-I ./spec/integration'
          t.pattern = ['./spec/integration/recipes/*_spec.rb']
        end
      end
    end
  end
end
