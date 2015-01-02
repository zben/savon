require "nori_v2"
require "savon_v2/soap_fault"
require "savon_v2/http_error"

module SavonV2
  class Response

    def initialize(http, globals, locals)
      @http    = http
      @globals = globals
      @locals  = locals

      build_soap_and_http_errors!
      raise_soap_and_http_errors! if @globals[:raise_errors]
    end

    attr_reader :http, :globals, :locals, :soap_fault, :http_error

    def success?
      !soap_fault? && !http_error?
    end
    alias_method :successful?, :success?

    def soap_fault?
      SOAPFault.present?(@http, xml)
    end

    def http_error?
      HTTPError.present? @http
    end

    def header
      find('Header')
    end

    def body
      find('Body')
    end

    alias_method :to_hash, :body

    def to_array(*path)
      result = path.inject body do |memo, key|
        return [] if memo[key].nil?
        memo[key]
      end

      result.kind_of?(Array) ? result.compact : [result].compact
    end

    def hash
      @hash ||= nori_v2.parse(xml)
    end

    def xml
      @http.body
    end

    alias_method :to_xml, :xml
    alias_method :to_s,   :xml

    def doc
      @doc ||= Nokogiri.XML(xml)
    end

    def xpath(path, namespaces = nil)
      doc.xpath(path, namespaces || xml_namespaces)
    end

    def find(*path)
      envelope = nori_v2.find(hash, 'Envelope')
      raise_invalid_response_error! unless envelope

      nori_v2.find(envelope, *path)
    end

    private

    def build_soap_and_http_errors!
      @soap_fault = SOAPFault.new(@http, nori_v2, xml) if soap_fault?
      @http_error = HTTPError.new(@http) if http_error?
    end

    def raise_soap_and_http_errors!
      raise soap_fault if soap_fault?
      raise http_error if http_error?
    end

    def raise_invalid_response_error!
      raise InvalidResponseError, "Unable to parse response body:\n" + xml.inspect
    end

    def xml_namespaces
      @xml_namespaces ||= doc.collect_namespaces
    end

    def nori_v2
      return @nori_v2 if @nori_v2

      nori_v2_options = {
        :strip_namespaces      => @globals[:strip_namespaces],
        :convert_tags_to       => @globals[:convert_response_tags_to],
        :convert_attributes_to => @globals[:convert_attributes_to],
        :advanced_typecasting  => @locals[:advanced_typecasting],
        :parser                => @locals[:response_parser]
      }

      non_nil_nori_v2_options = nori_v2_options.reject { |_, value| value.nil? }
      @nori_v2 = NoriV2.new(non_nil_nori_v2_options)
    end

  end
end
