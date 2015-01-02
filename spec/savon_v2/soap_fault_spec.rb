require "spec_helper"

describe SavonV2::SOAPFault do
  let(:soap_fault) { SavonV2::SOAPFault.new new_response(:body => Fixture.response(:soap_fault)), nori_v2 }
  let(:soap_fault2) { SavonV2::SOAPFault.new new_response(:body => Fixture.response(:soap_fault12)), nori_v2 }
  let(:soap_fault_nc) { SavonV2::SOAPFault.new new_response(:body => Fixture.response(:soap_fault)), nori_v2_no_convert }
  let(:soap_fault_nc2) { SavonV2::SOAPFault.new new_response(:body => Fixture.response(:soap_fault12)), nori_v2_no_convert }
  let(:another_soap_fault) { SavonV2::SOAPFault.new new_response(:body => Fixture.response(:another_soap_fault)), nori_v2 }
  let(:no_fault) { SavonV2::SOAPFault.new new_response, nori_v2 }

  let(:nori_v2) { NoriV2.new(:strip_namespaces => true, :convert_tags_to => lambda { |tag| tag.snakecase.to_sym }) }
  let(:nori_v2_no_convert) { NoriV2.new(:strip_namespaces => true, :convert_tags_to => nil) }

  it "inherits from SavonV2::Error" do
    expect(SavonV2::SOAPFault.ancestors).to include(SavonV2::Error)
  end

  describe "#http" do
    it "returns the HTTPI2::Response" do
      expect(soap_fault.http).to be_an(HTTPI2::Response)
    end
  end

  describe ".present?" do
    it "returns true if the HTTP response contains a SOAP 1.1 fault" do
      http = new_response(:body => Fixture.response(:soap_fault))
      expect(SavonV2::SOAPFault.present? http).to be_truthy
    end

    it "returns true if the HTTP response contains a SOAP 1.2 fault" do
      http = new_response(:body => Fixture.response(:soap_fault12))
      expect(SavonV2::SOAPFault.present? http).to be_truthy
    end

    it "returns true if the HTTP response contains a SOAP fault with different namespaces" do
      http = new_response(:body => Fixture.response(:another_soap_fault))
      expect(SavonV2::SOAPFault.present? http).to be_truthy
    end

    it "returns false unless the HTTP response contains a SOAP fault" do
      expect(SavonV2::SOAPFault.present? new_response).to be_falsey
    end
  end

  [:message, :to_s].each do |method|
    describe "##{method}" do
      it "returns a SOAP 1.1 fault message" do
        expect(soap_fault.send method).to eq("(soap:Server) Fault occurred while processing.")
      end

      it "returns a SOAP 1.2 fault message" do
        expect(soap_fault2.send method).to eq("(soap:Sender) Sender Timeout")
      end

      it "returns a SOAP fault message (with different namespaces)" do
        expect(another_soap_fault.send method).to eq("(ERR_NO_SESSION) Wrong session message")
      end

      it "works even if the keys are different in a SOAP 1.1 fault message" do
        expect(soap_fault_nc.send method).to eq("(soap:Server) Fault occurred while processing.")
      end

      it "works even if the keys are different in a SOAP 1.2 fault message" do
        expect(soap_fault_nc2.send method).to eq("(soap:Sender) Sender Timeout")
      end
    end
  end

  describe "#to_hash" do
    it "returns the SOAP response as a Hash unless a SOAP fault is present" do
      expect(no_fault.to_hash[:authenticate_response][:return][:success]).to be_truthy
    end

    it "returns a SOAP 1.1 fault as a Hash" do
      expected = {
        :fault => {
          :faultstring => "Fault occurred while processing.",
          :faultcode   => "soap:Server"
        }
      }

      expect(soap_fault.to_hash).to eq(expected)
    end

    it "returns a SOAP 1.2 fault as a Hash" do
      expected = {
        :fault => {
          :detail => { :max_time => "P5M" },
          :reason => { :text => "Sender Timeout" },
          :code   => { :value => "soap:Sender", :subcode => { :value => "m:MessageTimeout" } }
        }
      }

      expect(soap_fault2.to_hash).to eq(expected)
    end

    it "works even if the keys are different" do
      expected = {
        "Fault" => {
          "Code" => {
            "Value"  => "soap:Sender",
            "Subcode"=> {
              "Value" => "m:MessageTimeout"
            }
          },
          "Reason" => {
            "Text" => "Sender Timeout"
          },
          "Detail" => {
            "MaxTime" => "P5M"
          }
        }
      }

      expect(soap_fault_nc2.to_hash).to eq(expected)
    end
  end

  def new_response(options = {})
    defaults = { :code => 500, :headers => {}, :body => Fixture.response(:authentication) }
    response = defaults.merge options

    HTTPI2::Response.new response[:code], response[:headers], response[:body]
  end

end
