# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'disque_jockey/version'

Gem::Specification.new do |gem|
  gem.name          = 'disque_jockey'
  gem.version       = DisqueJockey::VERSION
  gem.authors       = ['Devin Riley']
  gem.email         = ['devinriley84+disque_jockey@gmail.com']
  gem.license       = "MIT"
  gem.description   = "A framework for managing and running ruby background workers."
  gem.summary       = "A background job framework."
  gem.homepage      = 'https://github.com/DevinRiley/disque_jockey'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = ['disque_jockey']
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ['lib']
  gem.add_runtime_dependency 'disque'
  gem.add_runtime_dependency 'logging'
  gem.add_runtime_dependency 'thor'
  gem.add_development_dependency('rspec', '~> 3.1', '>= 3.0')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('pry')
end
