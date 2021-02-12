require "bunny"

# Consume stuff from AMQP
class AMQPConsume
  def initialize(exchange:, queue:, bind: [])
    conn = Bunny.new
    conn.start
    channel = conn.create_channel
    _exchange = channel.topic(exchange)
    @queue = channel.queue(queue, durable: true, auto_delete: false)
    bind = [ bind ] unless bind.respond_to?(:each)
    bind.each { |binding| @queue.bind(_exchange, routing_key: binding) }
  end

  def consume
    @queue.consume(&proc)
  end
end
