# frozen_string_literal: true

module Iro
  module Runtime
    class Plugin
      attr_reader :eager_load_directories
      attr_reader :loader
      attr_reader :name
      attr_reader :root_path

      def initialize(name:, root_path:)
        @eager_load_directories = []
        @name = name
        @root_path = root_path

        setup_loader
      end

      def reload
        loader.reload
        eager_load
      end

      def setup
        loader.setup
        eager_load
      end

      private

      def eager_load
        eager_load_directories.each { |dir| loader.eager_load_dir(dir) }
      end

      def setup_loader
        @loader = Zeitwerk::Loader.new.tap do |loader|
          loader.tag = name
          loader.enable_reloading

          loader.on_load do |name, constant, path|
            Iro.logger.debug { "constant loaded #{name} from #{self.name}" }
            Support::Callback.resolve(type: :constant_loaded, name:, constant:, path:)
          end

          loader.on_unload do |name, constant|
            Iro.logger.debug { "constant unloaded #{name} from #{self.name}" }
            Support::Callback.resolve(type: :constant_unloaded, name:, constant:)
          end

          loader.push_dir(File.join(root_path, 'iro'), namespace: Iro)
          loader.collapse(File.join(root_path, 'iro/errors'))
        end
      end
    end
  end
end
