# frozen_string_literal: true

module Iro
  module Support
    module Inflection
      module_function

      def pascal_case(string)
        string.to_s.split('_').map(&:capitalize).join
      end

      def snake_case(string)
        string.to_s.gsub(/([A-Z]+)([A-Z][a-z])/, '\\1_\\2').gsub(/([a-z\d])([A-Z])/, '\\1_\\2').downcase
      end
    end
  end
end
