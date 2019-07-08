# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rack/lightning/version"

Gem::Specification.new do |spec|
  spec.name          = "rack-lightning"
  spec.version       = Rack::Lightning::VERSION
  spec.authors       = ["bumi"]
  spec.email         = ["hello@michaelbumann.com"]

  spec.summary       = %q{Rack middleware to request Bitcoin lightning payments}
  spec.description   = %q{Rack middleware that generates and validates paid lightning invoices}
  spec.homepage      = "https://github.com/bumi/rack-lightning"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "lnrpc", "= 0.6.1"
  spec.add_dependency "rack"
end
