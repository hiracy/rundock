require "bundler/gem_tasks"
require 'rspec/core/rake_task'

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
            Bundler.with_clean_env do
              system "./spec/integration/platformes/centos6/setup.sh &"

              # wait 60 and interval 10 seconds
              found = false
              6.times do
                system "sudo docker ps | grep rundock"
                if $?.to_i == 0
                  found = true
                  break
                end
                sleep 10
              end
              raise "Docker Error." unless found
            end
          end
        end
  
        desc "Run rundock for #{target}"

        task :rundock do
          Bundler.with_clean_env do
            if target == 'localhost'
              system 'rm -f /var/tmp/hello_rundock; bundle exec ./exe/rundock ssh -c "echo \'Hello Rundock.\' > /var/tmp/hello_rundock" -h localhost -l debug'
            else
              system "bundle exec ./exe/rundock ssh -c \"rm -f /var/tmp/hello_rundock;echo \'Hello Rundock.\' > /var/tmp/hello_rundock\" -h 127.0.0.1 -p 22222 -u tester -i /#{ENV['HOME']}/.ssh/id_rsa_rundock_spec_centos6_tmp -l debug"
            end
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
