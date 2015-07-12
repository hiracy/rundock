require 'rundock'
require 'open-uri'

module Rundock
  class Runner
    ScenarioNotFoundError = Class.new(StandardError)

    class << self
      def run(options)
        Logger.info 'Starting Rundoc:'

        runner = self.new(options)
        runner.build(options)
        runner.run
      end
    end

    attr_reader :scenario

    def initialize(options)
      @options = options
    end

    def run
      @scenario.run
    end

    def build(options)
      if options['scenario_yaml']
        unless FileTest.exist?(options['scenario_yaml'])
          raise ScenarioNotFoundError, "'#{options['scenario_yaml']}' scenario file is not found."
        end

        # parse scenario
        if options['scenario_yaml'] =~ %r{^(http|https)://}
          # read from http/https
          open(options['scenario_yaml']) do |f|
            @scenario = Rundock::Builder::ScenarioBuilder.new(options, f).build
          end
        else
          File.open(options['scenario_yaml']) do |f|
            @scenario = Rundock::Builder::ScenarioBuilder.new(options, f).build
          end
        end
      else
        @scenario = Rundock::Builder::ScenarioBuilder.new(options, nil).build
      end
    end
  end
end
