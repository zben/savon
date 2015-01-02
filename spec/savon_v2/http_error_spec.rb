require "spec_helper"

describe SavonV2::HTTPError do
  let(:http_error) { SavonV2::HTTPError.new new_response(:code => 404, :body => "Not Found") }
  let(:no_error) { SavonV2::HTTPError.new new_response }

  it "inherits from SavonV2::Error" do
    expect(SavonV2::HTTPError.ancestors).to include(SavonV2::Error)
  end

  describe ".present?" do
    it "returns true if there was an HTTP error" do
      http = new_response(:code => 404, :body => "Not Found")
      expect(SavonV2::HTTPError.present? http).to be_truthy
    end

    it "returns false unless there was an HTTP error" do
      expect(SavonV2::HTTPError.present? new_response).to be_falsey
    end
  end

  describe "#http" do
    it "returns the HTTPI2::Response" do
      expect(http_error.http).to be_a(HTTPI2::Response)
    end
  end

  [:message, :to_s].each do |method|
    describe "##{method}" do
      it "returns the HTTP error message" do
        expect(http_error.send method).to eq("HTTP error (404): Not Found")
      end
    end
  end

  describe "#to_hash" do
    it "returns the HTTP response details as a Hash" do
      expect(http_error.to_hash).to eq(:code => 404, :headers => {}, :body => "Not Found")
    end
  end

  def new_response(options = {})
    defaults = { :code => 200, :headers => {}, :body => Fixture.response(:authentication) }
    response = defaults.merge options

    HTTPI2::Response.new response[:code], response[:headers], response[:body]
  end

end
