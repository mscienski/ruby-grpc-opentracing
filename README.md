[![Build Status](https://travis-ci.org/iaintshine/ruby-grpc-opentracing.svg?branch=master)](https://travis-ci.org/iaintshine/ruby-grpc-opentracing)

# GRPC::OpenTracing

OpenTracing instrumentation for gRPC in Ruby. 

It's expected that usage of gRPC libraries across different languages will be consistent. That's why I've based the API on [GRPC-Java OpenTracing](https://github.com/grpc-ecosystem/grpc-opentracing/tree/master/java) using Ruby idioms at the same time.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grpc-opentracing'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grpc-opentracing

## Usage

If you want to add basic tracing to your clients and servers, you can do so in a few short and simple steps, as shown below. These code snippets use the gRPC example's `GreeterGrpc`, generated by protocol buffers.

The gem exposes two tracing and wrapping interceptors:
* One for client side `GRPC::OpenTracing::ClientInterceptor`, 
* and the other one for server side `GRPC::OpenTracing::ServerInterceptor`.

## Client Tracing

Steps:
- Instantiate a tracer
- Instantiate a client
- Create a `GRPC::OpenTracing::ClientInterceptor`
- Intercept the client channel

```ruby
require 'grpc'
require 'helloworld_services_pb'
require 'grpc-opentracing'

def build_client(host, creds)
  tracing_interceptor = GRPC::OpenTracing::ClientInterceptor.new(tracer: OpenTracing.global_tracer)
  client = Helloworld::Greeter::Stub.new(host, creds)
  tracing_interceptor.intercept(client)
end

def main
  stub = build_client('localhost:50051', :this_channel_is_insecure)
  message = stub.say_hello(Helloworld::HelloRequest.new(name: 'world')).message
end

main
```

### Client Configuration Options

* `tracer: OpenTracing::Tracer` an OT compatible tracer. Default `OpenTracing.global_tracer`
* `active_span: Proc` an active span provider. Default: `nil`.
* `decorators: Array[SpanDecorator]` a lists of span decorators. Default to `[RequestReplySpanDecorator]`

## Server Tracing

- Instantiate a tracer
- Create a `GRPC::OpenTracing::ServerInterceptor`
- Intercept a service

```ruby
require 'grpc'
require 'helloworld_services_pb'
require 'grpc-opentracing'

class GreeterServer < Helloworld::Greeter::Service
  def say_hello(hello_req, _unused_call)
    Helloworld::HelloReply.new(message: "Hello #{hello_req.name}")
  end
end

def main
  tracing_interceptor = GRPC::OpenTracing::ServerInterceptor.new(tracer: OpenTracing.global_tracer)
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(tracing_interceptor.intercept(GreeterServer))
  s.run_till_terminated
end

main
```

### Server Configuration Options

* `tracer: OpenTracing::Tracer` an OT compatible tracer. Default `OpenTracing.global_tracer`
* `active_span: Proc` an active span provider. Default: `nil`.
* `decorators: Array[SpanDecorator]` a lists of span decorators. Default to `[RequestReplySpanDecorator]`

## Decorators

Traced spans can be customized through decorators - `SpanDecorator` class. They're called once the processing of a request is done, no matter if the processing has finished with success or failure. 

You can provide a set of decorators during an interceptor creation e.g.

```ruby
class RequestSpanDecorator
  def self.call(span, method, request, response, error)
    span.set_tag('grpc.request', request.to_json) if request
  end
end

tracing_interceptor = GRPC::OpenTracing::ServerInterceptor.new(decorators: [RequestSpanDecorator])
tracing_interceptor = GRPC::OpenTracing::ClientInterceptor.new(decorators: [RequestSpanDecorator])
```

Notice that by default `RequestReplySpanDecorator` is attached, so if you want to preserve the behaviour make sure to append it to the `decorators` list.

### Decorator arguments 

* `span: OpenTracing::Span` the current active span. 
* `method: String` current method name in the `/service_name/method_name` form.
* `request` an instance of gRPC message class e.g. `Helloworld::HelloRequest`.
* `response` an instance of gRPC message class e.g. `Helloworld::HelloReply`.
* `error: Exception` an exception. Set in case of processing failure.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iaintshine/ruby-grpc-opentracing. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the GRPC::OpenTracing project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/iaintshine/ruby-grpc-opentracing/blob/master/CODE_OF_CONDUCT.md).
