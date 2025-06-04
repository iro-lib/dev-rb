# frozen_string_literal: true

module Iro
  class Chromaticity
    class XY < Chromaticity
      implements Model::XY do
        modify :x, display_precision: 8
        modify :y, display_precision: 8
      end
    end
  end
end
