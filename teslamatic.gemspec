# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teslamatic/version'

Gem::Specification.new do |gem|
  gem.name          = "teslamatic"
  gem.version       = Teslamatic::VERSION
  gem.authors       = ["George Scott"]
  gem.email         = ["gscott@rumbleware.com"]
  gem.description   = "Tesla Telematics API"
  gem.summary       = "Telsa Telematics API"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "rest-client", "~> 1.6.7"
  gem.add_runtime_dependency "json", "~> 1.7.6"

end
