require 'bunny'
require_relative 'logging'

module Avenue
  class Worker
    include Avenue::Logging

    attr_accessor :connection

    def initialize(broker, consumers)
      @broker = broker
      self.consumers = consumers
    end

    def run
      setup_queues
    end

    def setup_queues
      logger.info 'Setting up queues'
      @consumers.each { |consumer| setup_queue(consumer) }
    end

    def setup_queue(consumer)
      logger.info "Subscription Setup - Consumer: #{consumer}, Queue: #{consumer.get_queue_name}"

      queue = consumer.queue(@broker, consumer.get_queue_name)
      queue.subscribe(:manual_ack => true) do |delivery_info, properties, payload|
        handle_message(consumer, delivery_info, properties, payload)
      end
    end

    def handle_message(consumer, delivery_info, properties, payload)

      logger.info('Dispatching Message - ' +
                      "Routing Key: #{delivery_info.routing_key}, " +
                      "Consumer: #{consumer}, " +
                      "Payload: #{payload}")

      begin
        message = Avenue::Message.new(delivery_info, properties, payload)
        consumer.new.process(message)
        consumer.acknowledge(delivery_info.delivery_tag)

        logger.info('Handled Message - ' +
                        "Routing Key: #{delivery_info.routing_key}, " +
                        "Consumer: #{consumer}, " +
                        "Payload: #{payload}")
      rescue StandardError => ex
        prefix = "message(#{payload}): "
        logger.error prefix + "error in consumer '#{consumer}'"
        logger.error prefix + "#{ex.class} - #{ex.message}"
        logger.error (['backtrace:'] + ex.backtrace).join("\n")
      end

    end

    def consumers=(val)
      logger.warn "No consumer loaded, ensure there's no configuration issue" if val.empty?
      @consumers = val
    end
  end
end