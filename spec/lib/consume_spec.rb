require_relative '../../lib/consume'

describe 'AMQPConsume' do
  subject { AMQPConsume.new }
  it { is_expected.to respond_to(:consume) }
end
