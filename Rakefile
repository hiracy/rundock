require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc 'Run all tests.'
task :spec => 'spec:all'

namespace :spec do

  namespace :integration do
    targets = []
    Dir.glob('./spec/integration/platformes/*').each do |result|
      targets << File.basename(result)
    end

    task :all => targets

    targets.each do |target|
      desc "Run rundock and serverspec tests for #{target}"
      task target => ["rundock:#{target}", "serverspec:#{target}"]

      namespace :docker do
        desc "Setup Docker for #{target}"

        task target do
          Bundler.with_clean_env do
            system "./spec/integration/platformes/centos6/setup.sh"
            abort unless $?.exitstatus == 0
          end
        end
      end

      namespace :rundock do
        desc "Run rundock for #{target}"

        task target do
          Bundler.with_clean_env do
            bundle exec exec/rundock ssh -c hostname -h localhost
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
