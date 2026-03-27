require_relative "lib/agent_loop/version"

Gem::Specification.new do |spec|
  spec.name          = "agent-loop"
  spec.version       = AgentLoop::VERSION
  spec.authors       = ["Brandon Mathis"]
  spec.summary       = "Run Claude Code CLI in a loop, working tasks one by one from a Prompt.md"
  spec.homepage      = "https://github.com/BrandonMathis/agent-loop"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0.0"

  spec.files         = Dir["lib/**/*.rb", "bin/*", "*.md", "*.gemspec"]
  spec.bindir        = "bin"
  spec.executables   = ["agent-loop"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.2"
end
