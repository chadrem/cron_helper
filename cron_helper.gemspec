# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cron_helper/version'

Gem::Specification.new do |spec|
  spec.name          = "cron_helper"
  spec.version       = CronHelper::VERSION
  spec.authors       = ["Chad Remesch"]
  spec.email         = ["chad@remesch.com"]

  spec.summary       = %q{Cron Helper adds addition features to cron jobs scheduled by the Whenever gem.}
  spec.homepage      = "https://github.com/chadrem/cron_helper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
