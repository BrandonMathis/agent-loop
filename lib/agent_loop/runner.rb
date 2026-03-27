# frozen_string_literal: true

require 'digest'
require 'fileutils'
require_relative 'watcher'

module AgentLoop
  class Runner
    DONE = 'done'

    def initialize(options = {})
      @dangerous     = options[:dangerous]     || options['dangerous']     || false
      @prompt_file   = options[:prompt]        || options['prompt']        || 'Prompt.md'
      @poll_interval = (options[:poll_interval] || options['poll_interval'] || 0.5).to_f
    end

    def run
      setup_temp_files
      trap_signals

      loop do
        break if status_done?

        abort "Error: #{@prompt_file} not found." unless File.exist?(@prompt_file)

        FileUtils.rm_f(@status_file)
        puts 'Running agent loop iteration...'

        run_iteration(expand_prompt)

        break if status_done?
      end

      puts "AGENT_STATUS is 'done'. Stopping loop."
    end

    private

    def setup_temp_files
      loop_id      = Digest::SHA1.hexdigest("#{Dir.pwd}\n")[0, 8]
      @status_file = "/tmp/AGENT_STATUS_#{loop_id}"
      @task_file   = "/tmp/AGENT_TASK_#{loop_id}"
      FileUtils.rm_f([@status_file, @task_file])
    end

    def trap_signals
      handler = proc do
        puts 'Interrupted. Stopping loop.'
        exit 1
      end
      trap('INT',  handler)
      trap('TERM', handler)
    end

    def expand_prompt
      File.read(@prompt_file)
          .gsub('${STATUS_FILE}', @status_file)
          .gsub('${TASK_FILE}',   @task_file)
    end

    def run_iteration(prompt_text)
      stdin_r, stdin_w = IO.pipe
      stdin_w.write(prompt_text)
      stdin_w.close

      flags     = @dangerous ? ['--dangerously-skip-permissions'] : []
      agent_pid = spawn('claude', *flags, in: stdin_r)
      stdin_r.close

      watcher = Watcher.new(
        status_file: @status_file,
        task_file: @task_file,
        poll_interval: @poll_interval
      ).start(agent_pid) do |signal, pid|
        case signal
        when :task_done
          puts "AGENT_TASK is 'done'. Killing agent (PID #{pid})."
        when :status_done
          puts "AGENT_STATUS is 'done'. Killing agent (PID #{pid})."
        end
        kill_process(pid)
      end

      _, status = Process.waitpid2(agent_pid)
      watcher.stop

      return unless status.exitstatus.zero? && !status_done?

      puts 'Agent exited cleanly. Stopping loop.'
      exit 0
    end

    def kill_process(pid)
      Process.kill('TERM', pid)
    rescue Errno::ESRCH
      # Process already gone
    end

    def status_done?
      File.exist?(@status_file) && File.read(@status_file).strip == DONE
    end
  end
end
