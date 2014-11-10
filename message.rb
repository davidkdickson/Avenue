require 'multi_json'
require 'forwardable'

module Avenue
  class Message
    extend Forwardable

    attr_reader :delivery_info, :properties, :payload

    def initialize(delivery_info, properties, payload)
      @delivery_info = delivery_info
      @properties    = properties
      @payload       = payload
      @body          = MultiJson.load(payload, symbolize_keys: true)
    end

    def_delegator :@body, :[]
    def_delegators :@delivery_info, :routing_key, :exchange

    attr_reader :body

    def to_s
      attrs = { :@body => body.to_s, routing_key: routing_key }
      "#<Message #{attrs.map { |k,v| "#{k}=#{v.inspect}" }.join(', ')}>"
    end

    alias_method :inspect, :to_s
  end
end