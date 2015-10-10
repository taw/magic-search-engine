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

desc "Generate indexes"
task "index:generate" do
  indexer = Indexer.new
  indexer.save_all! "data/index.json"
  indexer.save_subset! "test/index/m10.json", "M10"
  indexer.save_subset! "test/index/rtr_block.json", "RTR", "GTC", "DGM"
  indexer.save_subset! "test/index/time_spiral_block.json", "TSP", "TSB", "PLC", "FUT"
  indexer.save_subset! "test/index/unsets.json", "UNG", "UNH", "pCEL"
  indexer.save_subset! "test/index/nph.json", "NPH"
  indexer.save_subset! "test/index/isd.json", "ISD", "DKA"
  indexer.save_subset! "test/index/al.json", "LEA"
end
