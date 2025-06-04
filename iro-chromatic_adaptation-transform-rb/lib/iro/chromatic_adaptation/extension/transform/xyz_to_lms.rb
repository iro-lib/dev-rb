# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    module Extension
      module Transform
        module XYZToLMS
          class << self
            def call(xyz, **options)
              cat = options.fetch(:cone_transform, Iro.config.default_cone_transform)

              vector = cat.column_vector(xyz)
              (cat * vector).to_a.flatten
            end
          end
        end
      end
    end
  end
end
