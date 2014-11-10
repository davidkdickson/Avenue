require_relative 'consumer'
require_relative 'worker'
require_relative 'logging'
require_relative 'message'
require_relative 'broker'

module Avenue
  include Avenue::Logging

  def self.register_consumer(consumer)
    self.consumers << consumer
  end

  def self.consumers
    @consumers ||= []
  end

  def self.broker
    @broker
  end

  def self.connect
    unless connected?
      @broker = Avenue::Broker.new
      @connected = true
    end
  end

  def self.connected?
    @connected
  end

  def self.publish(routing_key, message)
    # create a new connection every time we publish
    broker = Avenue::Broker.new
    broker.publish(routing_key, message)
    broker.close
  end
end