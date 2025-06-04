# frozen_string_literal: true

require 'zeitwerk'

root_path = File.dirname(__FILE__)

Zeitwerk::Loader.new.tap do |loader|
  loader.tag = 'iro-support'

  loader.on_load do |name, _constant, _path|
    Iro.logger.debug { "constant loaded #{name} from iro-support" } if Iro.respond_to?(:logger)
  end

  loader.on_unload do |name, _constant|
    Iro.logger.debug { "constant unloaded #{name} from iro-support" } if Iro.respond_to?(:logger)
  end

  loader.push_dir(root_path)
  loader.ignore(__FILE__)
  loader.collapse(File.join(root_path, 'iro/errors'))
end.setup
