# frozen_string_literal: true

module Iro
  module Support
    module ManagedAttributes
      class Attribute
        include Concurrent::InstanceVariable

        attr_reader :aliases
        attr_reader :coercer
        attr_reader :default
        attr_reader :dependencies
        attr_reader :name
        attr_reader :type
        attr_reader :validations

        def initialize(**options)
          @aliases      = options.fetch(:aliases, EMPTY_ARRAY)
          @coercer      = options.fetch(:coercer, ->(value) { value })
          @default      = options.fetch(:default, nil)
          @dependencies = options.fetch(:dependencies, EMPTY_ARRAY)
          @mutex        = Mutex.new
          @name         = options.fetch(:name).to_sym
          @required     = options.fetch(:required, false)
          @type         = options.fetch(:type, Type::Anything)
          @validations  = options.fetch(:validations, EMPTY_ARRAY)
        end

        def add_alias(new_name)
          new_aliases = aliases.dup.push(new_name).freeze
          concurrent_instance_variable_set(:aliases, new_aliases)
        end

        def add_validation(message, &validation)
          new_validations = validations.dup.push([validation, message].freeze).freeze
          concurrent_instance_variable_set(:validations, new_validations)
        end

        def required?
          @required
        end

        def to_hash
          { aliases:, coercer:, default:, dependencies:, name:, required: required?, type:, validations: }
        end
        alias to_h to_hash
      end
    end
  end
end
