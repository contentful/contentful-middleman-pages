# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contentful/middleman-pages/version'

Gem::Specification.new do |spec|
  spec.name          = "contentful-middleman-pages"
  spec.version       = Contentful::MiddlemanPages::VERSION
  spec.authors       = ["Farruco Sanjurjo"]
  spec.email         = ["madtrick@gmail.com"]
  spec.summary       = %q{Create pages in middleman using data imported with contentful_middleman}
  spec.homepage      = ""
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_dependency "hashugar", "~> 1.0"
  spec.add_dependency "addressable", "~> 2.3"
  spec.add_dependency "middleman-core", ">= 3.0"
  spec.add_dependency "contentful_middleman", "~> 1.3"
end
