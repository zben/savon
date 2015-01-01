require "savon_v2/mock"

module SavonV2
  module SpecHelper

    class Interface

      def mock!
        SavonV2.observers << self
      end

      def unmock!
        SavonV2.observers.clear
      end

      def expects(operation_name)
        expectation = MockExpectation.new(operation_name)
        expectations << expectation
        expectation
      end

      def expectations
        @expectations ||= []
      end

      def notify(operation_name, builder, globals, locals)
        expectation = expectations.shift

        if expectation
          expectation.actual(operation_name, builder, globals, locals)

          expectation.verify!
          expectation.response!
        else
          raise ExpectationError, "Unexpected request to the #{operation_name.inspect} operation."
        end
      rescue ExpectationError
        @expectations.clear
        raise
      end

      def verify!
        return if expectations.empty?
        expectations.each(&:verify!)
      rescue ExpectationError
        @expectations.clear
        raise
      end

    end

    def savon_v2
      @savon_v2 ||= Interface.new
    end

    def verify_mocks_for_rspec
      super if defined? super
      savon_v2.verify!
    end

  end
end
