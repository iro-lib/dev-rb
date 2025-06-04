# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    class Transform
      class CAT02 < Transform
        transform(
          [0.7328, 0.4296, -0.1624],
          [-0.7036, 1.6975, 0.0061],
          [0.0030, 0.0136, 0.9834],
        )
      end
    end
  end
end
