require "savon_v2/qualified_message"
require "gyoku_v1"

module SavonV2
  class Message

    def initialize(message_tag, namespace_identifier, types, used_namespaces, message, element_form_default, key_converter)
      @message_tag = message_tag
      @namespace_identifier = namespace_identifier
      @types = types
      @used_namespaces = used_namespaces

      @message = message
      @element_form_default = element_form_default
      @key_converter = key_converter
    end

    def to_s
      return @message.to_s unless @message.kind_of? Hash

      if @element_form_default == :qualified
        @message = QualifiedMessage.new(@types, @used_namespaces, @key_converter).to_hash(@message, [@message_tag.to_s])
      end

      gyoku_v1_options = {
        :element_form_default => @element_form_default,
        :namespace            => @namespace_identifier,
        :key_converter        => @key_converter
      }

      GyokuV1.xml(@message, gyoku_v1_options)
    end

  end
end
