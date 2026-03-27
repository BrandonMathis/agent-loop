require "digest"
require "fileutils"

module AgentLoop
  class Runner
    def initialize(task_file_path:, dangerous: false)
      @task_list = TaskList.new(task_file_path)
      @dangerous = dangerous

      loop_id = Digest::SHA1.hexdigest(Dir.pwd)[0, 8]
      @status_file = "/tmp/AGENT_STATUS_#{loop_id}"
      @task_file = "/tmp/AGENT_TASK_#{loop_id}"

      @agent_pid = nil
      @watcher_pid = nil
    end

    def run
      cleanup_signals
      setup_trap

      loop do
        break if done?(@status_file)

        unless File.exist?(@task_list.path)
          puts "Error: #{@task_list.path} not found. Exiting."
          exit 1
        end

        @task_list.reload!

        if @task_list.all_done?
          puts "All tasks complete!"
          break
        end

        current_task = @task_list.next_task
        task_index = @task_list.tasks.index { |t| t.pending? }

        FileUtils.rm_f(@task_file)
        puts "Running agent loop iteration..."
        puts "  Working on: #{current_task.description}"

        prompt = Prompt.new(
          task_list: @task_list,
          task_file: @task_file,
          status_file: @status_file
        ).build

        run_claude(prompt)

        # After claude finishes, check if it signaled task done
        if done?(@task_file)
          FileUtils.rm_f(@task_file)
          @task_list.reload!
          @task_list.complete_task!(task_index)
          puts "  Task complete: #{current_task.description}"
        end

        break if done?(@status_file)
        break if @agent_exit_status == 0
      end

      puts "Agent loop finished."
    ensure
      cleanup_signals
    end

    private

    def done?(path)
      File.exist?(path) && File.read(path).strip == "done"
    end

    def cleanup_signals
      FileUtils.rm_f(@status_file)
      FileUtils.rm_f(@task_file)
    end

    def setup_trap
      Signal.trap("INT") do
        puts "\nInterrupted. Stopping loop."
        kill_processes
        exit 1
      end

      Signal.trap("TERM") do
        puts "\nTerminated. Stopping loop."
        kill_processes
        exit 1
      end
    end

    def kill_processes
      Process.kill("TERM", @agent_pid) if @agent_pid rescue nil
      Process.kill("TERM", @watcher_pid) if @watcher_pid rescue nil
      Process.wait(@agent_pid) if @agent_pid rescue nil
      Process.wait(@watcher_pid) if @watcher_pid rescue nil
    end

    def run_claude(prompt)
      claude_args = ["claude"]
      claude_args << "--dangerously-skip-permissions" if @dangerous

      # Pass prompt via stdin pipe
      reader, writer = IO.pipe
      @agent_pid = Process.spawn(*claude_args, in: reader)
      writer.write(prompt)
      writer.close
      reader.close

      # Start watcher thread to monitor signal files
      @watcher_pid = start_watcher

      _pid, status = Process.wait2(@agent_pid)
      @agent_exit_status = status.exitstatus || 1

      # Stop watcher
      Process.kill("TERM", @watcher_pid) rescue nil
      Process.wait(@watcher_pid) rescue nil

      @agent_pid = nil
      @watcher_pid = nil
    end

    def start_watcher
      fork do
        loop do
          if done?(@task_file)
            puts "  Task signaled done. Stopping agent."
            Process.kill("TERM", @agent_pid) rescue nil
            break
          end

          if done?(@status_file)
            puts "  All tasks signaled done. Stopping agent."
            Process.kill("TERM", @agent_pid) rescue nil
            break
          end

          sleep 0.5
        end
      end
    end
  end
end
