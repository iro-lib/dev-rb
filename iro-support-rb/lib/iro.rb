# frozen_string_literal: true

module Iro
  EMPTY_ARRAY = [].freeze
  private_constant :EMPTY_ARRAY

  EMPTY_HASH = {}.freeze
  private_constant :EMPTY_HASH

  LOGGER_FORMATTER = proc do |severity, timestamp, program_name, message|
    formatted_datetime     = timestamp.strftime('%Y-%m-%d %H:%M:%S.%L')
    formatted_severity     = "[#{severity}]"
    formatted_program_name = program_name ? "Iro (#{program_name})" : 'Iro'

    "#{formatted_datetime} #{formatted_severity} #{formatted_program_name}: #{message}\n"
  end

  extend Support::Concurrent::InstanceVariable

  class << self
    def logger
      concurrent_instance_variable_fetch(:logger) do
        require 'logger'

        logger           = Logger.new($stdout)
        logger.level     = Logger::INFO
        logger.formatter = LOGGER_FORMATTER
        logger
      end
    end

    def logger=(logger)
      logger.formatter = LOGGER_FORMATTER if logger.respond_to?(:formatter=)
      concurrent_instance_variable_set(:logger, logger)
    end
  end
end
