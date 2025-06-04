# frozen_string_literal: true

require 'iro-support'
require_relative 'iro'
require 'zeitwerk'

root_path = File.dirname(__FILE__)

Zeitwerk::Loader.new.tap do |loader|
  loader.tag = 'iro-runtime'

  loader.on_load do |name, _constant, _path|
    Iro.logger.debug { "constant loaded #{name} from iro-runtime" }
  end

  loader.on_unload do |name, _constant|
    Iro.logger.debug { "constant unloaded #{name} from iro-runtime" }
  end

  loader.inflector.inflect(
    'dsl' => 'DSL',
  )

  loader.push_dir(File.join(root_path, 'iro'), namespace: Iro)
  loader.collapse(File.join(root_path, 'iro/errors'))
end.setup
