# -*- encoding: utf-8 -*-
require File.expand_path('../lib/asciidoc-merger/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Vince Verberckt"]
  gem.email         = ["vince@verberckt.com"]
  gem.description   = %q{Merge different asciidoc files into 1 big file.}
  gem.summary       = %q{Merge different asciidoc files into 1 big file.}
  gem.homepage      = "http://github.com"
  gem.files         = Dir['Gemfile', 'lib/**/*', 'test/**/*']
  gem.test_files    = Dir['test/**/*']
  gem.name          = "asciidoc-merger"
  gem.require_paths = ["lib"]
  gem.version       = AsciiDocMerger::VERSION
  gem.add_development_dependency 'rake'
end