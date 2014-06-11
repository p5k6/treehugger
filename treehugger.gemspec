# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'treehugger/version'

Gem::Specification.new do |spec|
  spec.name          = "treehugger"
  spec.version       = Treehugger::VERSION
  spec.authors       = ["Josh Stanfield"]
  spec.email         = ["josh.stanfield@livingsocial.com"]
  spec.summary       = %q{Treehugger: a gem to parse a Hive query's abstract syntax tree}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('aruba')
  spec.add_development_dependency('rake', '~> 0.9.2')
  spec.add_dependency('methadone', '~> 1.4.0')
  spec.add_development_dependency('rspec')
end
