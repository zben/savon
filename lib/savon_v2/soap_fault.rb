require "savon_v2"

module SavonV2
  class SOAPFault < Error

    def self.present?(http, xml = nil)
      xml ||= http.body
      fault_node  = xml.include?("Fault>")
      soap1_fault = xml.include?("faultcode>") && xml.include?("faultstring>")
      soap2_fault = xml.include?("Code>") && xml.include?("Reason>")

      fault_node && (soap1_fault || soap2_fault)
    end

    def initialize(http, nori_v2, xml = nil)
      @xml = xml
      @http = http
      @nori_v2 = nori_v2
    end

    attr_reader :http, :nori_v2, :xml

    def to_s
      fault = nori_v2.find(to_hash, 'Fault')
      message_by_version(fault)
    end

    def to_hash
      parsed = nori_v2.parse(xml || http.body)
      nori_v2.find(parsed, 'Envelope', 'Body')
    end

    private

    def message_by_version(fault)
      if nori_v2.find(fault, 'faultcode')
        code = nori_v2.find(fault, 'faultcode')
        text = nori_v2.find(fault, 'faultstring')

        "(#{code}) #{text}"
      elsif nori_v2.find(fault, 'Code')
        code = nori_v2.find(fault, 'Code', 'Value')
        text = nori_v2.find(fault, 'Reason', 'Text')

        "(#{code}) #{text}"
      end
    end

  end
end
