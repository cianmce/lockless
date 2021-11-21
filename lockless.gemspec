# frozen_string_literal: true

require_relative "lib/lockless/version"

Gem::Specification.new do |spec|
  spec.name = "lockless"
  spec.version = Lockless::VERSION
  spec.authors = ["Cian McElhinney"]
  spec.email = ["lockless@cme.33mail.com"]

  spec.summary = "Concurrently update records without locks."
  spec.description = "."
  spec.homepage = "https://github.com/cianmce/lockless"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_development_dependency "standardrb", "~> 1.0"
  spec.add_development_dependency "bundler", ">= 1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "pry", "~> 0.13.0"
  spec.add_development_dependency "pry-byebug", "~> 3.9"
  spec.add_development_dependency "pry-doc", "~> 1.1"
  spec.add_development_dependency "guard", "~> 2.18"
  spec.add_development_dependency "guard-rspec", "~> 4.7.3"
  spec.add_development_dependency "with_model", "~> 2.0"
  spec.add_development_dependency "database_cleaner", "~> 1.5"
  spec.add_development_dependency "sqlite3"
  spec.add_dependency "activerecord", ">= 4.0"
end
