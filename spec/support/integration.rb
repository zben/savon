module SpecSupport

  def call_and_fail_gracefully(client, *args, &block)
    client.call(*args, &block)
  rescue SavonV2::SOAPFault => e
    pending e.message
  end

end
