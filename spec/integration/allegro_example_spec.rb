 require "spec_helper"

describe "Allegro example" do

  it "works" do
    HTTPI.adapter = :net_http

    client = Savon.client(
      # The WSDL document provided by the service.
      :wsdl => "https://webapi.allegro.pl/uploader.php?wsdl",

      # Lower timeouts so these specs don't take forever when the service is not available.
      :open_timeout => 10,
      :read_timeout => 10,

      # Not needed?
      # ssl_verify_mode: :none,
      # ssl_version: :TLSv1,

      # Disable logging for cleaner spec output.
      :log => false,

      # Do not raise SOAP faults. We're using an invalid API key for this spec, so we expect
      # the server to raise an error.
      :raise_errors => false
    )

    message = { "sysver" => 1, "country-id" => 1, "webapi-key" => "WEBAPIKEY" }
    response = client.call(:do_query_sys_status, message: message)

    expect(response).to_not be_successful

    faultcode = response.body[:fault][:faultcode]
    expect(faultcode).to eq("ERR_WEBAPI_KEY")
  end

end
