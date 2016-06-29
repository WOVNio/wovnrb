# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wovnrb/version'

Gem::Specification.new do |spec|
  spec.name          = "wovnrb"
  spec.version       = Wovnrb::VERSION
  spec.authors       = ["Jeff Sandford", "Antoine David"]
  spec.email         = ["jeff@wovn.io"]
  spec.summary       = %q{Gem for WOVN.io}
  spec.description   = %q{Ruby gem for WOVN backend on Rack.}
  spec.homepage      = "https://github.com/WOVNio/wovnrb"
  spec.license       = "MIT"


  files = `git ls-files -z`.split("\x0")
  files.delete('BEFORE_PUSHING')
  spec.files         = files
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  #spec.require_paths = ["lib", "ext"]
  #spec.extensions    = spec.files.grep(%r{/extconf\.rb$})
  #spec.extensions    = %w[ext/dom/extconf.rb]
  #spec.extensions    = spec.files.grep(%r{/extconf\.rb$})

  spec.add_dependency "nokogumbo", "1.3.0"
  spec.add_dependency "activesupport", "~> 0"
  spec.add_dependency "lz4-ruby", "~> 0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "listen", "~> 3.0", ">= 3.0.6"
  ##spec.add_development_dependency "mocha"
  #spec.add_development_dependency "rspec"
  #spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "test-unit", "~> 0"
  spec.add_development_dependency "test-unit-notify", "~> 0"
  spec.add_development_dependency "minitest", "~> 0"
  spec.add_development_dependency "terminal-notifier", "~> 0"
  spec.add_development_dependency "guard", "~> 0"
  spec.add_development_dependency "guard-rspec", "~> 0"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "pry-remote", "~> 0"
  spec.add_development_dependency "pry-nav", "~> 0"
  #spec.add_development_dependency "rice"
  spec.add_development_dependency "rake-compiler", "~> 0"
  spec.add_development_dependency "geminabox", "~> 0"
  spec.add_development_dependency "timecop", "~> 0"
  spec.add_development_dependency "webmock", "~> 0"

end

