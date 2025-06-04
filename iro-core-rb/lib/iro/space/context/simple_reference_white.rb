# frozen_string_literal: true

module Iro
  module Space
    class Context
      class SimpleReferenceWhite < Context
        attribute :illuminant
        attribute :observer

        compute_attribute(:reference_white, allow_override: true) do
          if observer.respond_to?(:cmf) && illuminant.respond_to?(:spd)
            observer.cmf.spd_to_xyz(illuminant.spd)
          elsif illuminant.is_a?(Symbol) && Reference::White.const_defined?(illuminant)
            Reference::White.const_get(illuminant)
          end
        end
      end
    end
  end
end
