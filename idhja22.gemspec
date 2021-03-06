# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'idhja22/version'

Gem::Specification.new do |gem|
  gem.name          = "idhja22"
  gem.version       = Idhja22::VERSION
  gem.authors       = ["Henry Addison"]
  gem.description   = %q{Classifiers}
  gem.summary       = %q{A gem for creating classifiers (decision trees and naive Bayes so far)}
  gem.homepage      = "https://github.com/henryaddison/idhja22"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec", "~>2.10"
  gem.add_development_dependency "rake"
  gem.add_development_dependency 'debugger'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'

  gem.add_dependency 'configuration'
end
