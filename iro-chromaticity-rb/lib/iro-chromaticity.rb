# frozen_string_literal: true

require 'iro-core'
require 'iro-runtime'
require 'iro-support'

root_path = File.dirname(__FILE__)

Iro.plug('iro-chromaticity', root_path) do
  loader do
    inflect(
      'xy' => 'XY',
      'xy_to_xyz' => 'XYToXYZ',
      'xyz_to_xy' => 'XYZToXY',
    )
  end

  color do
    model(:xy) do
      component :x, :x, :linear
      component :y, :y, :linear
    end

    space(:xy) { Iro::Chromaticity::XY }

    transform(:xy, :xyz) { Iro::Chromaticity::Transform::XYToXYZ }
    transform(:xyz, :xy) { Iro::Chromaticity::Transform::XYZToXY }
  end
end
