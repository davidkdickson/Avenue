require 'logger'

module Avenue
  module Logging

    def self.setup_logger(target = $stdout)
      @logger = Logger.new(target)
      @logger
    end

    def self.logger
      @logger || setup_logger
    end

    def self.logger=(logger)
      @logger = logger
    end

    def logger
      Logging.logger
    end
  end
end