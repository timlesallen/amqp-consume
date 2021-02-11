describe 'AMQPConsume' do
  it { is_expected.to respond_to(:new) }
  it { is_expected.to respond_to(:consume) }
end
