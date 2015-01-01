
module SavonV2
  module CoreExt
    module String

      def self.included(base)
        unless "savon_v2".respond_to?(:snakecase)
          base.send(:include, Extension)
        end
      end

      module Extension
        def snakecase
          str = dup
          str.gsub! /::/, '/'
          str.gsub! /([A-Z]+)([A-Z][a-z])/, '\1_\2'
          str.gsub! /([a-z\d])([A-Z])/, '\1_\2'
          str.tr! ".", "_"
          str.tr! "-", "_"
          str.downcase!
          str
        end
      end

    end
  end
end

String.send :include, SavonV2::CoreExt::String
