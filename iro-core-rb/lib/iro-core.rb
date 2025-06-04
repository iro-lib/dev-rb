# frozen_string_literal: true

require 'iro-runtime'
require 'iro-support'

root_path = File.dirname(__FILE__)

Iro.plug('iro-core', root_path) do
  loader do
    inflect(
      'lms' => 'LMS',
      'lru_store' => 'LRUStore',
      'rec601' => 'REC601',
      'xyz' => 'XYZ',
    )
  end

  color do
    model(:lms) do
      component :long,   :l, :linear
      component :medium, :m, :linear
      component :short,  :s, :linear
    end

    model(:xyz) do
      component :x,         :x, :linear
      component :luminance, :y, :linear
      component :z,         :z, :linear
    end

    space(:lms) { Iro::LMS }
    space(:xyz) { Iro::XYZ }
  end

  on_load('Iro::RGB::Standard') do
    enhance_module('Iro::Reference::RGB') do
      override_constant(:STANDARD_XYZ_TRANSFORM) { |_| Iro::RGB::Standard.xyz_encoding_matrix }
    end
  end
end

require_relative 'iro'
