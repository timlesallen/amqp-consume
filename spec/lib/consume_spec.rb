require_relative '../../lib/consume'
require 'bunny'

describe 'AMQPConsume' do
  let(:exchange_name) { 'my-exchange' }
  let(:queue_name) { 'my-queue' }
  let(:connection) {
    conn = Bunny.new
    conn.start
    conn
  }
  let(:channel) { connection.create_channel }

  describe '.new' do
    subject { AMQPConsume.new(exchange: exchange_name, queue: queue_name) }

    before do
     # before each example, start rabbitmq and reset it
     system 'docker-compose', 'up', '-d', 'rabbitmq', out: File::NULL, err: File::NULL
     system 'docker-compose', 'exec', '--log-level', 'CRITICAL', 'rabbitmq', 'rabbitmqctl', 'stop_app', out: File::NULL, err: File::NULL
     system 'docker-compose', 'exec',  'rabbitmq', 'rabbitmqctl', 'reset', out: File::NULL, err: File::NULL
     system 'docker-compose', 'exec', 'rabbitmq', 'rabbitmqctl', 'start_app', out: File::NULL, err: File::NULL
     system 'docker-compose', 'exec', 'rabbitmq', 'rabbitmqctl', 'await_startup', out: File::NULL, err: File::NULL
    end

    it { is_expected.to respond_to(:consume) }

    context 'exchange exists' do
      before do
        channel.topic(exchange_name)
      end

      it "doesn't error" do
        subject
        expect(connection.exchange_exists? exchange_name).to equal(true)
      end
    end

    it 'creates exchange if not exists' do
      subject
      expect(connection.exchange_exists? exchange_name).to equal(true)
    end

    it 'declares the queue' do
      subject
      expect(connection.queue_exists? queue_name).to equal(true)
    end
  end

  describe '.consume' do
    it 'can receive messages on all the bindings given' do
      AMQPConsume.new(exchange: exchange_name, queue: queue_name, bind: 'blerg')
      exchange = channel.topic(exchange_name)
      exchange.publish('eat some bananas', routing_key: 'blerg')
      received = false
      received
    end
  end
end
