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
  spec.homepage      = ""
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

  spec.add_dependency "nokogumbo", "1.4.1"
  spec.add_dependency "nokogiri", "< 1.6.8.1"
  spec.add_dependency "activesupport", "< 5"
  spec.add_dependency "lz4-ruby"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "listen", "~> 3.0.6"
  ##spec.add_development_dependency "mocha"
  #spec.add_development_dependency "rspec"
  #spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-notify"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "terminal-notifier"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "pry-nav"
  #spec.add_development_dependency "rice"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "geminabox"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "webmock", '~> 2.1.0'
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "public_suffix", '~> 1.4.6'
end

