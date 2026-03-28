# frozen_string_literal: true

require 'tempfile'

RSpec.describe AgentLoop::Watcher do
  let(:status_file) { Tempfile.new('status').path }
  let(:task_file) { Tempfile.new('task').path }
  let(:watcher) do
    described_class.new(
      status_file: status_file,
      task_file: task_file,
      poll_interval: 0.05
    )
  end

  after do
    watcher.stop
    FileUtils.rm_f([status_file, task_file])
  end

  describe '#start' do
    it "detects when the status file contains 'done'" do
      signal_received = nil
      File.write(status_file, 'done')

      watcher.start(999) do |signal, _pid|
        signal_received = signal
      end
      watcher.join

      expect(signal_received).to eq(:status_done)
    end

    it "detects when the task file contains 'done'" do
      signal_received = nil
      FileUtils.rm_f(status_file)
      File.write(task_file, 'done')

      watcher.start(999) do |signal, _pid|
        signal_received = signal
      end
      watcher.join

      expect(signal_received).to eq(:task_done)
    end

    it 'passes the agent pid to the callback' do
      pid_received = nil
      File.write(status_file, 'done')

      watcher.start(42) do |_signal, pid|
        pid_received = pid
      end
      watcher.join

      expect(pid_received).to eq(42)
    end
  end

  describe '#stop' do
    it 'stops the watcher thread' do
      FileUtils.rm_f([status_file, task_file])

      watcher.start(999) { |_signal, _pid| nil }
      watcher.stop

      expect(watcher.instance_variable_get(:@stop)).to be true
    end
  end
end
