# frozen_string_literal: true

require 'digest'

module Iro
  module Cache
    module Identity
      class << self
        def generate(object)
          Digest::SHA256.hexdigest(Marshal.dump(serialize_to_cache_attributes(object)))
        end

        private

        def serialize_to_cache_attributes(object)
          if object.respond_to?(:cache_attributes, true)
            serialize_to_cache_attributes(object.send(:cache_attributes))
          elsif object.is_a?(Array)
            object.map { |o| serialize_to_cache_attributes(o) }
          elsif object.is_a?(Hash)
            object.transform_keys { |k| serialize_to_cache_attributes(k) }
                  .transform_values { |v| serialize_to_cache_attributes(v) }
          else
            object
          end
        end
      end
    end
  end
end
