# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'treehugger/version'

Gem::Specification.new do |spec|
  spec.name          = "treehugger"
  spec.version       = TreeHugger::VERSION
  spec.authors       = ["Josh Stanfield"]
  spec.email         = ["josh.stanfield@livingsocial.com"]
  spec.summary       = %q{Treehugger: a gem to parse a Hive query's abstract syntax tree}
  spec.description   = %q{parses the abstract syntax tree into a tree structure (TreeHugger::Tree object). Primarily intended to return list of columns used by the query, along with database and tables required.}
  spec.homepage      = "https://github.com/livingsocial/treehugger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency('rdoc', '~> 4.1', '>= 4.1.1')
  spec.add_development_dependency('aruba', '~> 0.5', '>= 0.5.4')
  spec.add_development_dependency('pry', '~> 0.10', '>= 0.10.0')
  spec.add_development_dependency('rake', '~> 0.9', '>= 0.9.2')
  spec.add_dependency('methadone', '~> 1.4', '>= 1.4.0')
  spec.add_development_dependency('rspec', '~> 3.0', '>= 3.0.0')
end
