require 'rundock'
require 'open-uri'

module Rundock
  class Runner
    ScenarioNotFoundError = Class.new(StandardError)
    RUNDOCK_PLUGINS = %w(operation hook)

    class << self
      def run(options)
        Logger.debug 'Starting Rundock:'

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
      if options[:scenario] || options[:targetgroup]
        raise ScenarioNotFoundError, "'#{options[:scenario]}' scenario file is not found." if options[:scenario] &&
                                                                                              !FileTest.exist?(options[:scenario])
        raise ScenarioNotFoundError, "'#{options[:targetgroup]}' targetgroup file is not found." if options[:command] &&
                                                                                                    options[:targetgroup] &&
                                                                                                    !FileTest.exist?(options[:targetgroup])

        options[:scenario] = options[:targetgroup] if options[:command] && options[:targetgroup]

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
      # load from current lib dir(for development)
      Dir.glob('./lib/rundock/plugin/**/*.rb').each do |f|
        require f.gsub(/.rb$/, '')
      end

      # load from local project
      Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/plugin/**/*.rb").each do |f|
        require f.gsub(/.rb$/, '')
      end

      # load from installed gems
      gems = []
      Gem::Specification.each do |gem|
        gems << gem.name
      end
      gems.uniq!

      gems.each do |g|
        RUNDOCK_PLUGINS.each do |plugin|
          next if g !~ /^(rundock-plugin-#{plugin})-/
          next if Gem::Specification.find_by_name(g).nil?
          Logger.debug("Loading rundock plugin: #{g}")
          libdir = "#{Gem::Specification.find_by_name(g).full_gem_path}/lib/#{Regexp.last_match(1).tr('-', '/')}"
          Dir.glob("#{libdir}/*.rb").each do |f|
            require f.gsub(/.rb$/, '')
          end
        end
      end
    end
  end
end
