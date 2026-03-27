# Agent Loop

A command line utility that runs Claude Code CLI in a loop to work tasks one by one from a Prompt.md

## Project Goals
1. Can be cloned down and run with minimal setup
1. This project can work in existing repos with minimal configuration
1. Zero dependencies other than Claude Code and bash

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/BrandonMathis/agent-loop/main/old_runner/install.sh)
```

This downloads `start_agent_loop.sh` and `Prompt.md` into your current directory.

## Usage
1. Edit `Prompt.md` with your tasks
2. Run agent loop script

**Human Assisted**
```
./start_agent_loop.sh
```

**Fully Automated**
```
./start_agent_loop.sh --dangerous
``` 

When running this script with the `--dangerous` flag you are giving claude code cli [full permission to do whatever it pleases via the `--dangerously-skip-permissions`](https://code.claude.com/docs/en/settings#permission-settings) flag. Please proceed with caution and consider all possible risks.
