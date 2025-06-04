# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    module Extension
      module Transform
        module LMSToXYZ
          class << self
            def call(xyz, **options)
              cat = options.fetch(:cone_transform, Iro.config.default_cone_transform)

              vector = cat.column_vector(xyz)
              (cat.inverse * vector).to_a.flatten
            end
          end
        end
      end
    end
  end
end
