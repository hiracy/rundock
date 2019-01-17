lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rundock/version'

Gem::Specification.new do |spec|
  spec.name          = 'rundock'
  spec.version       = Rundock::VERSION
  spec.authors       = ['hiracy']
  spec.email         = ['leizhen@mbr.nifty.com']

  spec.summary       = 'Simple and extensible server orchestration framework'
  spec.homepage      = 'https://github.com/hiracy/rundock'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'serverspec', '~> 2.1'

  spec.add_runtime_dependency 'ansi'
  spec.add_runtime_dependency 'highline'
  spec.add_runtime_dependency 'net-ssh'
  spec.add_runtime_dependency 'specinfra', ['>= 2.31.0', '< 3.0.0']
  spec.add_runtime_dependency 'thor'
end
