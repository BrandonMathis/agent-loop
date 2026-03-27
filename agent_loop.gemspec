require_relative "lib/agent_loop/version"

Gem::Specification.new do |spec|
  spec.name          = "agent-loop"
  spec.version       = AgentLoop::VERSION
  spec.authors       = ["Brandon Mathis"]
  spec.summary       = "Run Claude Code CLI in a loop, working tasks off a YAML task list"
  spec.description   = "A command line utility that runs Claude Code CLI in a loop to work tasks one by one from a tasks.yml file"
  spec.homepage      = "https://github.com/BrandonMathis/agent-loop"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0.0"

  spec.files         = Dir["lib/**/*.rb", "exe/*", "*.gemspec", "Gemfile", "Readme.md", "LICENSE"]
  spec.bindir        = "exe"
  spec.executables   = ["agent-loop"]

  spec.require_paths = ["lib"]
end
