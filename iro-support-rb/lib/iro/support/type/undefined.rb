# frozen_string_literal: true

module Iro
  module Support
    module Type
      Undefined = Object.new.tap do |undefined|
        def undefined.===(other)
          self == other
        end

        def undefined.clone(**)
          self
        end

        def undefined.dup
          self
        end

        def undefined.inspect
          to_s
        end

        def undefined.to_s
          'Undefined'
        end
      end
    end
  end
end
