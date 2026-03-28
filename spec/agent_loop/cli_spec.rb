# frozen_string_literal: true

RSpec.describe AgentLoop::CLI do
  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  it 'has start as the default task' do
    expect(described_class.default_command).to eq('start')
  end
end
