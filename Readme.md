# Agent Loop

A Ruby gem that runs Claude Code CLI in a loop, working tasks one by one from a YAML task list.

## Project Goals
1. Can be installed as a gem and run with minimal setup
2. Works in existing repos with minimal configuration
3. Uses a structured YAML task list instead of markdown

## Install

```bash
gem install agent-loop
```

Or add to your Gemfile:

```ruby
gem "agent-loop"
```

## Usage

### 1. Create a `tasks.yml` file

```yaml
prompt: |
  You are a helpful coding assistant. Execute the task given to you.
  Work carefully and verify your work before marking the task as done.

tasks:
  - description: Create a new Rails controller for users
    status: pending
  - description: Add index and show actions with JSON responses
    status: pending
  - description: Write request specs for the users controller
    status: pending
```

### 2. Run the agent loop

**Human Assisted** (default - requires approval for each action):
```bash
agent-loop
```

**Fully Automated:**
```bash
agent-loop --dangerous
```

**Custom task file:**
```bash
agent-loop --file my_tasks.yml
```

### Task File Format

The `tasks.yml` file has two sections:

- **prompt** - Instructions that are sent to Claude with every iteration. Use this to set context, coding standards, or constraints.
- **tasks** - A list of tasks with `description` and `status` fields. Status is either `pending` or `done`.

As the agent loop runs, it picks the first `pending` task, sends it to Claude, and marks it `done` in the YAML file when complete.

## How It Works

1. Reads `tasks.yml` and finds the first pending task
2. Builds a prompt combining your custom prompt with the task list
3. Pipes the prompt to `claude` CLI via stdin
4. A watcher process monitors for task completion signals
5. When Claude signals "done", the task is marked complete in `tasks.yml`
6. Loop repeats until all tasks are done

## Warning

When running with `--dangerous` you are giving Claude Code CLI [full permission via `--dangerously-skip-permissions`](https://code.claude.com/docs/en/settings#permission-settings). Proceed with caution.
