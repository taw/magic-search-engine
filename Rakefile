require "rake/testtask"
require "pathname"
require "json"

# ActiveRecord FTW
class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end
end

class Pathname
  def write_at(content)
    parent.mkpath
    write(content)
  end
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.options = "-s0" # random order is just annoying
  t.verbose = true
end

desc "Generate test indexes"
task "index:generate:test" do
  full_db = Pathname("data/AllSets-x.json")
  @db = JSON.parse(full_db.read)
  Pathname("test/index/m10.json").write_at(@db.slice("M10").to_json)
  Pathname("test/index/rtr_block.json").write_at(@db.slice("RTR", "GTC", "DGM").to_json)
end

desc "Generate full indexes"
task "index:generate:full" do
  # Nothing to do, we currently use unindexed data
end
