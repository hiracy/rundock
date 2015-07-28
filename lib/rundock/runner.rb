require 'rundock'
require 'open-uri'

module Rundock
  class Runner
    ScenarioNotFoundError = Class.new(StandardError)
    RUNDOCK_PLUGINS = %w(operation hook)

    class << self
      def run(options)
        Logger.debug 'Starting Rundoc:'

        runner = self.new(options)
        runner.load_plugins
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
      if options[:scenario] || options[:hostgroup]
        if options[:scenario] && !FileTest.exist?(options[:scenario])
          raise ScenarioNotFoundError, "'#{options[:scenario]}' scenario file is not found."
        elsif options[:hostgroup] && !FileTest.exist?(options[:hostgroup])
          raise ScenarioNotFoundError, "'#{options[:hostgroup]}' hostgroup file is not found."
        end

        options[:scenario] = options[:hostgroup] if options[:hostgroup]

        # parse scenario
        if options[:scenario] =~ %r{^(http|https)://}
          # read from http/https
          open(options[:scenario]) do |f|
            @scenario = Rundock::Builder::ScenarioBuilder.new(options, f).build
          end
        else
          File.open(options[:scenario]) do |f|
            @scenario = Rundock::Builder::ScenarioBuilder.new(options, f).build
          end
        end
      else
        # do rundock ssh
        @scenario = Rundock::Builder::ScenarioBuilder.new(options, nil).build
      end
    end

    def load_plugins
      Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/plugin/**/*.rb").each do |f|
        require f.gsub(/.rb$/, '')
      end

      gems = []
      Gem::Specification.each do |gem|
        gems << gem.name
      end
      gems.uniq!

      gems.each do |g|
        RUNDOCK_PLUGINS.each do |plugin|
          next if g !~ /^(rundock-plugin-#{plugin})-/
          next if Gem::Specification.find_by_path(g).nil?
          Logger.debug("Loading rundock plugin: #{g}")
          libdir = "#{Gem::Specification.find_by_path(g).full_gem_path}/lib/rundock/plugin/#{Regexp.last_match(0)}"
          Dir.glob("#{libdir}/*.rb").each do |f|
            require f.gsub(/.rb$/, '')
          end
        end
      end
    end
  end
end
