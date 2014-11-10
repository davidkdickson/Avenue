module Avenue
  module Consumer

    attr_accessor :channel

    def self.included(base)
      base.extend(ClassMethods)
      Avenue.register_consumer(base)
      @consumer_pool_size = 1
    end

    module ClassMethods

      def consumer_pool_size(consumer_pool_size)
        @consumer_pool_size = consumer_pool_size
      end

      def prefetch(prefetch)
        @prefetch = prefetch
      end

      def queue_name(name)
        @queue_name = name
      end

      def create_channel(broker)
        @channel = broker.connection.create_channel(nil, @consumer_pool_size)
        if @prefetch
          @channel.prefetch(@prefetch)
        end
        @channel
      end

      def queue(broker, name)
        @channel ||= create_channel(broker)
        @channel.queue(name, durable: true)
      end

      def acknowledge(delivery_tag)
        @channel.ack(delivery_tag, false)
      end

      def get_queue_name
        return @queue_name unless @queue_name.nil?
        queue_name = self.name.gsub(/::/, ':')
        queue_name.gsub!(/([^A-Z:])([A-Z])/) { "#{$1}_#{$2}" }
        queue_name.downcase
      end
    end
  end
end