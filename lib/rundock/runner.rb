require 'rundock'
require 'open-uri'

module Rundock
  class Runner
    ScenarioNotFoundError = Class.new(StandardError)

    class << self
      def run(options)
        Logger.debug 'Starting Rundoc:'

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
      if options['scenario'] || options['hostgroup']
        if options['scenario'] && !FileTest.exist?(options['scenario'])
          raise ScenarioNotFoundError, "'#{options['scenario']}' scenario file is not found."
        elsif options['hostgroup'] && !FileTest.exist?(options['hostgroup'])
          raise ScenarioNotFoundError, "'#{options['hostgroup']}' hostgroup file is not found."
        end

        options['scenario'] = options['hostgroup'] if options['hostgroup']

        # parse scenario
        if options['scenario'] =~ %r{^(http|https)://}
          # read from http/https
          open(options['scenario']) do |f|
            @scenario = Rundock::Builder::ScenarioBuilder.new(options, f).build
          end
        else
          File.open(options['scenario']) do |f|
            @scenario = Rundock::Builder::ScenarioBuilder.new(options, f).build
          end
        end
      else
        # do rundock ssh
        @scenario = Rundock::Builder::ScenarioBuilder.new(options, nil).build
      end
    end
  end
end
