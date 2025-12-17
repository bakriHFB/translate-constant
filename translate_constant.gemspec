# frozen_string_literal: true

require_relative "lib/translate_constant/version"

Gem::Specification.new do |spec|
  spec.name = "translate_constant"
  spec.version = TranslateConstant::VERSION
  spec.authors = ["bakriHFB"]
  spec.email = ["abubaker.hussein@jisr.net"]

  spec.summary = "Translate array constants to labels via I18n."
  spec.description = "Helpers to translate array constants into localized, human-friendly labels using I18n."
  spec.homepage = "https://rubygems.org/gems/translate_constant"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  # spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  # RDoc disabled; documentation will be provided on GitHub

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies (pessimistic constraints to avoid open-ended warnings)
  spec.add_dependency "activesupport", "~> 6.1"
  spec.add_dependency "i18n", "~> 1.10"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
