require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc 'Run all tests.'
task :spec => 'spec:integration:all'

namespace :spec do

  namespace :integration do

    namespace :local do
      desc "Run rundock for localhost"
      task :rundock do
        system 'rm -f /var/tmp/hello_rundock; bundle exec ./exe/rundock ssh -c "echo \'Hello Rundock.\' > /var/tmp/hello_rundock" -h localhost'
      end
  
      desc "Run serverspec tests for localhost"
      RSpec::Core::RakeTask.new(:serverspec) do |t|
        ENV['TARGET_HOST'] = 'localhost'
        t.ruby_opts = '-I ./spec/integration'
        t.pattern = "./spec/integration/recipes/*_spec.rb"
      end
    end

    targets = []
    Dir.glob('./spec/integration/platformes/*').each do |result|
      targets << File.basename(result)
    end

    task :all => targets

    targets.each do |target|
      desc "Run rundock and serverspec tests for #{target}"
      task target => [
        "docker:#{target}",
        "rundock_remote:#{target}",
        "serverspec_remote:#{target}",
      ]

      namespace :docker do
        desc "Setup Docker for #{target}"

        task target do
          Bundler.with_clean_env do
            system "./spec/integration/platformes/centos6/setup.sh &"
            abort unless $?.exitstatus == 0
          end
        end
      end

      namespace :rundock do
        desc "Run rundock for #{target}"

        task target do
          Bundler.with_clean_env do
            system "bundle exec ./exe/rundock ssh -c 'hostname' -h 172.30.4.225 -u hiraishi_yosuke -i ~/.ssh/id_rsa_hiraishi -p 10022"
          end
        end
      end

      namespace :serverspec do
        desc "Run serverspec tests for #{target}"
        RSpec::Core::RakeTask.new(target.to_sym) do |t|
          ENV['TARGET_HOST'] = target
          t.ruby_opts = '-I ./spec/integration'
          t.pattern = "./spec/integration/recipes/*_spec.rb"
        end
      end
    end
  end
end
