# frozen_string_literal: true

RSpec.describe 'AgentLoop::VERSION' do
  it 'is a string' do
    expect(AgentLoop::VERSION).to be_a(String)
  end

  it 'follows semantic versioning' do
    expect(AgentLoop::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
