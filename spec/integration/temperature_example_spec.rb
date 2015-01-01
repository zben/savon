 require "spec_helper"

describe "Temperature example" do

  it "converts 30 degrees celsius to 86 degrees fahrenheit" do
    client = SavonV2.client do
      # The WSDL document provided by the service.
      wsdl "http://www.webservicex.net/ConvertTemperature.asmx?WSDL"

      # Needed because (up until now), SavonV2 doesn't match XS types to Hash keys,
      # but defaults to convert Hash message Symbols (like :from_unit) to lowerCamelCase.
      # The service expects these to be CamelCase instead. Look at SavonV2's log output
      # and compare it with an example request generated by soapUI.
      convert_request_keys_to :camelcase

      # Lower timeouts so these specs don't take forever when the service is not available.
      open_timeout 10
      read_timeout 10

      # Disable logging for cleaner spec output.
      log false
    end

    response = call_and_fail_gracefully(client, :convert_temp) do
      # For the corrent values to pass for :from_unit and :to_unit, I searched the WSDL for
      # the "FromUnit" type which is a "TemperatureUnit" enumeration that looks like this:
      #
      # <s:simpleType name="TemperatureUnit">
      #   <s:restriction base="s:string">
      #     <s:enumeration value="degreeCelsius"/>
      #     <s:enumeration value="degreeFahrenheit"/>
      #     <s:enumeration value="degreeRankine"/>
      #     <s:enumeration value="degreeReaumur"/>
      #     <s:enumeration value="kelvin"/>
      #   </s:restriction>
      # </s:simpleType>
      #
      # Support for XS schema types needs to be improved.
      message(:temperature => 30, :from_unit => "degreeCelsius", :to_unit => "degreeFahrenheit")
    end

    fahrenheit = response.body[:convert_temp_response][:convert_temp_result]
    expect(fahrenheit).to eq("86")
  end

end
