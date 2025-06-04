# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    class Transform
      class VonKries < Transform
        transform(
          [0.40024, 0.70760, -0.08081],
          [-0.22630, 1.16532, 0.04570],
          [0.00000, 0.00000, 0.91822],
        )
      end
    end
  end
end
