# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "grpc/opentracing/version"

Gem::Specification.new do |spec|
  spec.name          = "grpc-opentracing"
  spec.version       = GRPC::OpenTracing::VERSION
  spec.authors       = ["iaintshine"]
  spec.email         = ["bodziomista@gmail.com"]

  spec.summary       = %q{OpenTracing instrumentation for gRPC in Ruby.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/iaintshine/ruby-grpc-opentracing"
  spec.license       = "Apache-2.0"

  spec.required_ruby_version = ">= 2.2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'grpc'
  spec.add_dependency "multi_json"
  spec.add_dependency 'opentracing'
  spec.add_dependency "method-tracer"

  spec.add_development_dependency "test-tracer"
  spec.add_development_dependency "tracing-matchers"
  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "rspec", "~> 3"
end
