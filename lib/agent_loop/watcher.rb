# frozen_string_literal: true

module AgentLoop
  class Watcher
    DONE = 'done'

    def initialize(status_file:, task_file:, poll_interval: 0.5)
      @status_file   = status_file
      @task_file     = task_file
      @poll_interval = poll_interval
      @thread        = nil
      @stop          = false
    end

    # Starts the background watcher thread. Yields :task_done or :status_done
    # to the block when a signal file is detected.
    def start(agent_pid, &callback)
      @stop = false
      @thread = Thread.new do
        loop do
          break if @stop

          if done?(@task_file)
            FileUtils.rm_f(@task_file)
            callback.call(:task_done, agent_pid)
            break
          end

          if done?(@status_file)
            callback.call(:status_done, agent_pid)
            break
          end

          sleep @poll_interval
        end
      end
      self
    end

    def stop
      @stop = true
      @thread&.join(2)
    end

    def join
      @thread&.join
    end

    private

    def done?(path)
      File.exist?(path) && File.read(path).strip == DONE
    end
  end
end
