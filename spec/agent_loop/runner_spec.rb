# frozen_string_literal: true

RSpec.describe AgentLoop::Runner do
  describe '#initialize' do
    it 'accepts symbol keys' do
      runner = described_class.new(dangerous: true, prompt: 'Custom.md', poll_interval: 1.0)

      expect(runner.instance_variable_get(:@dangerous)).to be true
      expect(runner.instance_variable_get(:@prompt_file)).to eq('Custom.md')
      expect(runner.instance_variable_get(:@poll_interval)).to eq(1.0)
    end

    it 'accepts string keys' do
      runner = described_class.new('dangerous' => false, 'prompt' => 'Other.md', 'poll_interval' => 2.0)

      expect(runner.instance_variable_get(:@dangerous)).to be false
      expect(runner.instance_variable_get(:@prompt_file)).to eq('Other.md')
      expect(runner.instance_variable_get(:@poll_interval)).to eq(2.0)
    end

    it 'uses default values' do
      runner = described_class.new

      expect(runner.instance_variable_get(:@dangerous)).to be false
      expect(runner.instance_variable_get(:@prompt_file)).to eq('Prompt.md')
      expect(runner.instance_variable_get(:@poll_interval)).to eq(0.5)
    end
  end
end
