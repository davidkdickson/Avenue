require 'bunny'
require_relative 'logging'

module Avenue
  class Broker
    include Avenue::Logging

    attr_accessor :connection

    def initialize
      @connection = Bunny.new
      @connection.start
      logger.info "Connected tn host #{@connection.host}"
    end

    def publish(routing_key, message)
      logger.info("publishing message '#{message.inspect}' to #{routing_key}")
      publish_channel = connection.create_channel
      publish_channel.default_exchange.publish(JSON.dump(message), :routing_key => routing_key)
      publish_channel.close
    end

    def close
      @connection.close
    end
  end
end