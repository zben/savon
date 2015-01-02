require "spec_helper"
require "integration/support/server"

describe SavonV2::Client do

  before :all do
    @server = IntegrationServer.run
  end

  after :all do
    @server.stop
  end

  describe ".new" do
    it "supports a block without arguments to create a client with global options" do
      client = SavonV2.client do
        wsdl Fixture.wsdl(:authentication)
      end

      expect(client.globals[:wsdl]).to eq(Fixture.wsdl(:authentication))
    end

    it "supports a block with one argument to create a client with global options" do
      client = SavonV2.client do |globals|
        globals.wsdl Fixture.wsdl(:authentication)
      end

      expect(client.globals[:wsdl]).to eq(Fixture.wsdl(:authentication))
    end

    it "builds an HTTPI2 request for WasabiV3" do
      http_request = mock
      wsdl_request = mock(:build => http_request)
      SavonV2::WSDLRequest.expects(:new).with(instance_of(SavonV2::GlobalOptions)).returns(wsdl_request)

      WasabiV3::Document.any_instance.expects(:request=).with(http_request)
      SavonV2.client(:wsdl => "http://example.com")
    end

    it "raises if initialized with anything other than a Hash" do
      expect { SavonV2.client("http://example.com") }.
        to raise_error(SavonV2::InitializationError, /Some code tries to initialize SavonV2 with the "http:\/\/example\.com" \(String\)/)
    end

    it "raises if not initialized with either a :wsdl or both :endpoint and :namespace options" do
      expect { SavonV2.client(:endpoint => "http://example.com") }.
        to raise_error(SavonV2::InitializationError, /Expected either a WSDL document or the SOAP endpoint and target namespace options/)
    end

    it "raises a when given an unknown option via the Hash syntax" do
      expect { SavonV2.client(:invalid_global_option => true) }.
        to raise_error(SavonV2::UnknownOptionError, "Unknown global option: :invalid_global_option")
    end

    it "raises a when given an unknown option via the block syntax" do
      expect { SavonV2.client { another_invalid_global_option true } }.
        to raise_error(SavonV2::UnknownOptionError, "Unknown global option: :another_invalid_global_option")
    end
  end

  describe "#globals" do
    it "returns the current set of global options" do
      expect(new_client.globals).to be_an_instance_of(SavonV2::GlobalOptions)
    end

    fit "defaults :log to false" do
      client = SavonV2.client(:wsdl => Fixture.wsdl(:authentication))
      expect(client.globals[:log]).to be_falsey
    end
  end

  describe "#service_name" do
    it "returns the name of the service" do
      expect(new_client.service_name).to eq('AuthenticationWebServiceImplService')
    end
  end

  describe "#operations" do
    it "returns all operation names" do
      operations = new_client.operations
      expect(operations).to eq([:authenticate])
    end

    it "raises when there is no WSDL document" do
      expect { new_client_without_wsdl.operations }.to raise_error("Unable to inspect the service without a WSDL document.")
    end
  end

  describe "#operation" do
    it "returns a new SOAP operation" do
      operation = new_client.operation(:authenticate)
      expect(operation).to be_a(SavonV2::Operation)
    end

    it "raises if there's no such SOAP operation" do
      expect { new_client.operation(:does_not_exist) }.
        to raise_error(SavonV2::UnknownOperationError)
    end

    it "does not raise when there is no WSDL document" do
      new_client_without_wsdl.operation(:does_not_exist)
    end
  end

  describe "#call" do
    it "calls a new SOAP operation" do
      locals = { :message => { :symbol => "AAPL" } }
      soap_response = new_soap_response

      wsdl = WasabiV3::Document.new('http://example.com')
      operation = SavonV2::Operation.new(:authenticate, wsdl, SavonV2::GlobalOptions.new)
      operation.expects(:call).with(locals).returns(soap_response)

      SavonV2::Operation.expects(:create).with(
        :authenticate,
        instance_of(WasabiV3::Document),
        instance_of(SavonV2::GlobalOptions)
      ).returns(operation)

      response = new_client.call(:authenticate, locals)
      expect(response).to eq(soap_response)
    end

    it "supports a block without arguments to call an operation with local options" do
      client = new_client(:endpoint => @server.url(:repeat))

      response = client.call(:authenticate) do
        message(:symbol => "AAPL" )
      end

      expect(response.http.body).to include("<symbol>AAPL</symbol>")
    end

    it "supports a block with one argument to call an operation with local options" do
      client = new_client(:endpoint => @server.url(:repeat))

      # supports instance variables!
      @instance_variable = { :symbol => "AAPL" }

      response = client.call(:authenticate) do |locals|
        locals.message(@instance_variable)
      end

      expect(response.http.body).to include("<symbol>AAPL</symbol>")
    end

    it "accepts arguments for the message tag" do
      client   = new_client(:endpoint => @server.url(:repeat))
      response = client.call(:authenticate, :attributes => { "ID" => "ABC321"})

      expect(response.http.body).to include('<tns:authenticate ID="ABC321">')
    end

    it "raises when the operation name is not a symbol" do
      expect { new_client.call("not a symbol") }.to raise_error(
        ArgumentError,
        "Expected the first parameter (the name of the operation to call) to be a symbol\n" \
        "Actual: \"not a symbol\" (String)"
      )
    end

    it "raises a when given an unknown option via the Hash syntax" do
      expect { new_client.call(:authenticate, :invalid_local_option => true) }.
        to raise_error(SavonV2::UnknownOptionError, "Unknown local option: :invalid_local_option")
    end

    it "raises a when given an unknown option via the block syntax" do
      expect { new_client.call(:authenticate) { another_invalid_local_option true } }.
        to raise_error(SavonV2::UnknownOptionError, "Unknown local option: :another_invalid_local_option")
    end
  end

  describe "#build_request" do
    it "returns the request without making an actual call" do
      expected_request = mock('request')
      wsdl = WasabiV3::Document.new('http://example.com')

      operation = SavonV2::Operation.new(
        :authenticate,
        wsdl,
        SavonV2::GlobalOptions.new
      )
      operation.expects(:request).returns(expected_request)

      SavonV2::Operation.expects(:create).with(
        :authenticate,
        instance_of(WasabiV3::Document),
        instance_of(SavonV2::GlobalOptions)
      ).returns(operation)

      operation.expects(:call).never

      client = new_client(:endpoint => @server.url(:repeat))
      request = client.build_request(:authenticate) do
        message(:symbol => "AAPL" )
      end

      expect(request).to eq expected_request
    end

    it "accepts a block without arguments" do
      client = new_client(:endpoint => @server.url(:repeat))
      request = client.build_request(:authenticate) do
        message(:symbol => "AAPL" )
      end

      expect(request.body).
        to include('<tns:authenticate><symbol>AAPL</symbol></tns:authenticate>')
    end

    it "accepts a block with one argument" do
      client = new_client(:endpoint => @server.url(:repeat))

      # supports instance variables!
      @instance_variable = { :symbol => "AAPL" }

      request = client.build_request(:authenticate) do |locals|
        locals.message(@instance_variable)
      end

      expect(request.body).
        to include("<tns:authenticate><symbol>AAPL</symbol></tns:authenticate>")
    end

    it "accepts argument for the message tag" do
      client = new_client(:endpoint => @server.url(:repeat))
      request = client.build_request(:authenticate, :attributes => { "ID" => "ABC321" })

      expect(request.body).
        to include("<tns:authenticate ID=\"ABC321\"></tns:authenticate>")
    end

    it "raises when the operation name is not a symbol" do
      expect { new_client.build_request("not a symbol") }.to raise_error
    end

    it "raises when given an unknown option via the Hash syntax" do
      expect { new_client.build_request(:authenticate, :invalid_local_option => true) }.to raise_error
    end

    it "raises when given an unknown option via the block syntax" do
      expect { new_client.build_request(:authenticate) { another_invalid_local_option true } }.to raise_error
    end
  end

  def new_http_response(options = {})
    defaults = { :code => 200, :headers => {}, :body => Fixture.response(:authentication) }
    response = defaults.merge options

    HTTPI2::Response.new response[:code], response[:headers], response[:body]
  end

  def new_soap_response(options = {})
    http = new_http_response(options)
    globals = SavonV2::GlobalOptions.new
    locals = SavonV2::LocalOptions.new

    SavonV2::Response.new(http, globals, locals)
  end

  def new_client(globals = {})
    globals = { :wsdl => Fixture.wsdl(:authentication), :log => false }.merge(globals)
    SavonV2.client(globals)
  end

  def new_client_without_wsdl(globals = {})
    globals = { :endpoint => "http://example.co", :namespace => "http://v1.example.com", :log => false }.merge(globals)
    SavonV2.client(globals)
  end

end
