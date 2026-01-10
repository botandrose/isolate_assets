# frozen_string_literal: true

require_relative "lib/engine_assets/version"

Gem::Specification.new do |spec|
  spec.name = "engine_assets"
  spec.version = EngineAssets::VERSION
  spec.authors = ["Micah Geisel"]
  spec.email = ["micah@botandrose.com"]

  spec.summary = "Self-contained asset serving for Rails engines"
  spec.description = "Serve JavaScript, CSS, and other assets from your Rails engine without depending on Sprockets, Propshaft, or the host application's asset pipeline."
  spec.homepage = "https://github.com/botandrose/engine_assets"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 8.0"
end
