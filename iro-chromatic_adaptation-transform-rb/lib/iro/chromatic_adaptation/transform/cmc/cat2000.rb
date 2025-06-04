# frozen_string_literal: true

module Iro
  module ChromaticAdaptation
    class Transform
      module CMC
        class CAT2000 < Transform
          transform(
            [0.7982, 0.3389, -0.1371],
            [-0.5918, 1.5512, 0.0406],
            [0.0008, 0.0239, 0.9753],
          )
        end
      end
    end
  end
end
