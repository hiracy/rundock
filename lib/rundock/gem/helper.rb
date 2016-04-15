require 'bundler/vendored_thor' unless defined?(Thor)
require 'bundler'

module Rundock
  module Gem
    class Helper < Bundler::GemHelper
      def install
        desc "Run rundock with default configuration"
        task :rundock => 'rundock:do'

        namespace :rundock do
          desc 'Run rundock with scenariofile.(env:SCENARIO_FILE_PATH)'
          task 'do' do
            if ENV['SCENARIO_FILE_PATH']
              system("rundock do #{ENV['SCENARIO_FILE_PATH']}")
            else
              system('rundock do')
            end
          end
        end
      end
    end
  end
end


