# frozen_string_literal: true

require "thor"
require_relative "runner"

module AgentLoop
  class CLI < Thor
    desc "start", "Run the agent loop in the current directory"
    long_desc <<~LONGDESC
      Reads Prompt.md (or the file given by --prompt), expands ${STATUS_FILE}
      and ${TASK_FILE} placeholders, and runs `claude` in a loop until the
      agent writes "done" to the status file.
    LONGDESC

    method_option :dangerous,
                  type:    :boolean,
                  default: false,
                  desc:    "Pass --dangerously-skip-permissions to claude"

    method_option :prompt,
                  type:    :string,
                  default: "Prompt.md",
                  aliases: "-p",
                  desc:    "Path to the prompt template file"

    method_option :poll_interval,
                  type:    :numeric,
                  default: 0.5,
                  aliases: "-i",
                  desc:    "Seconds between watcher poll checks"

    def start
      Runner.new(options).run
    end

    default_task :start

    def self.exit_on_failure?
      true
    end
  end
end
