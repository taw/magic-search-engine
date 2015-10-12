require "rake/testtask"
require "pathname"
require "json"
require_relative "lib/indexer"

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.options = "-s0" # random order is just annoying
  t.verbose = true
end

desc "Generate index"
task "index:generate" do
  indexer = Indexer.new
  indexer.save_all! "data/index.json"
end
