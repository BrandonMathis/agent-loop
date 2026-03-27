require "yaml"

module AgentLoop
  class TaskList
    attr_reader :path, :prompt

    def initialize(path)
      @path = File.expand_path(path)
      reload!
    end

    def reload!
      data = YAML.safe_load_file(@path, permitted_classes: [Symbol])
      @prompt = data.fetch("prompt", "")
      @tasks = data.fetch("tasks", []).map { |t| Task.new(t) }
    end

    def tasks
      @tasks.dup
    end

    def pending_tasks
      @tasks.select(&:pending?)
    end

    def next_task
      pending_tasks.first
    end

    def all_done?
      pending_tasks.empty?
    end

    def complete_task!(index)
      @tasks[index].status = "done"
      save!
    end

    def save!
      data = {
        "prompt" => @prompt,
        "tasks" => @tasks.map(&:to_h)
      }
      File.write(@path, YAML.dump(data))
    end

    class Task
      attr_accessor :description, :status

      def initialize(hash)
        @description = hash.fetch("description")
        @status = hash.fetch("status", "pending")
      end

      def pending?
        @status == "pending"
      end

      def done?
        @status == "done"
      end

      def to_h
        { "description" => @description, "status" => @status }
      end
    end
  end
end
