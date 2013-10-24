# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'folio/version'

Gem::Specification.new do |spec|
  spec.name          = "folio-pagination-legacy"
  spec.version       = Folio::VERSION
  spec.authors       = ["Jacob Fugal"]
  spec.email         = ["jacob@instructure.com"]
  spec.description   = %q{A pagination library.}
  spec.summary       = %q{
    Folio is a library for pagination. It's meant to be nearly compatible
    with WillPaginate, but with broader -- yet more well-defined -- semantics
    to allow for sources whose page identifiers are non-ordinal.

    This version of the gem is for legacy Rails 2.3 support. If you're running
    Rails 3 or newer, you want the folio-pagination gem.
  }
  spec.homepage      = "https://github.com/instructure/folio/tree/legacy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
