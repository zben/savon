require 'httpi2/adapter/httpclient'

# Proxy adapter. Records all requests and passes them to HTTPClient
class AdapterForTest < HTTPI2::Adapter::Base

  register :adapter_for_test

  def initialize(request)
    @@requests ||= []
    @@requests.push request
    @request = request
    @worker = HTTPI2::Adapter::HTTPClient.new(request)
  end

  def client
    @worker.client
  end

  def request(method)
    @@methods ||= []
    @@methods.push method
    @worker.request(method)
  end

end

# Fake adapter with request recording.
# Takes path from url and returns fixture WSDL with that name.
class FakeAdapterForTest < HTTPI2::Adapter::Base

  register :fake_adapter_for_test

  def initialize(request)
    @@requests ||= []
    @@requests.push request
    @request = request
  end

  attr_reader :client

  def request(method)
    @@methods ||= []
    @@methods.push method
    target = @request.url.path.to_sym
    HTTPI2::Response.new(200, {}, Fixture.wsdl(target))
  end

end
