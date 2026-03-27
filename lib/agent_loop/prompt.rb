module AgentLoop
  class Prompt
    def initialize(task_list:, task_file:, status_file:)
      @task_list = task_list
      @task_file = task_file
      @status_file = status_file
    end

    def build
      task = @task_list.next_task

      if task.nil?
        return all_done_prompt
      end

      task_index = @task_list.tasks.index { |t| t.pending? }
      formatted_tasks = format_task_list

      <<~PROMPT
        #{@task_list.prompt}

        ## Current Task List
        #{formatted_tasks}

        ## Instructions
        1. Work on the FIRST pending task: "#{task.description}"
        2. Complete the work described in that task
        3. When finished, write "done" to the file `#{@task_file}` using the Bash tool

        If you cannot complete the task, still write "done" to `#{@task_file}` and explain what went wrong.
      PROMPT
    end

    private

    def all_done_prompt
      <<~PROMPT
        All tasks are complete. Write "done" to the file `#{@status_file}` using the Bash tool.
      PROMPT
    end

    def format_task_list
      @task_list.tasks.map.with_index do |task, i|
        marker = task.done? ? "[x]" : "[ ]"
        "- #{marker} #{task.description}"
      end.join("\n")
    end
  end
end
