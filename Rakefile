#require "bundler/gem_tasks"
#require 'rake/extensiontask'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*/*.rb']
  t.options = '-p'
end

desc 'Run tests'
task :default => :test

#Rake::ExtensionTask.new 'dom' do |ext|
#  ext.lib_dir = 'lib/wovnrb'
#end

#gemspec = Gem::Specification.load('wovnrb.gemspec')
#Rake::ExtensionTask.new do |ext|
#	ext.name = 'dom'
#	ext.source_pattern = "*.{cpp,h}"
#	ext.ext_dir = 'ext/wovnrb'
#	ext.lib_dir = 'lib/wovnrb'
#	ext.gem_spec = gemspec
#end
#
#task :default => [:compile]

