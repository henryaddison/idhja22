# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'idhja22/version'

Gem::Specification.new do |gem|
  gem.name          = "idhja22"
  gem.version       = Idhja22::VERSION
  gem.authors       = ["Henry Addison"]
  gem.description   = %q{Decision Trees}
  gem.summary       = %q{A different take on decision trees}
  gem.homepage      = "https://github.com/henryaddison/idhja22"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
