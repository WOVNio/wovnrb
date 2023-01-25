lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wovnrb/version'

Gem::Specification.new do |spec|
  spec.name          = 'wovnrb'
  spec.version       = Wovnrb::VERSION
  spec.authors       = ['Wovn Technologies, Inc.']
  spec.email         = ['dev@wovn.io']
  spec.summary       = 'Gem for WOVN.io'
  spec.description   = 'Ruby gem for WOVN backend on Rack.'
  spec.homepage      = 'https://wovn.io'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.5'
  spec.metadata['rubygems_mfa_required'] = 'true'

  files = `git ls-files -z`.split("\x0")
  files.delete('BEFORE_PUSHING')
  spec.files         = files
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'addressable'
  spec.add_dependency 'lz4-ruby'
  spec.add_dependency 'nokogiri', '>= 1.12', '<2'
  spec.add_dependency 'rack'
end
