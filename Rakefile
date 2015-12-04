require "rake/testtask"
require "pathname"
require "fileutils"

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.options = "-s0" # random order is just annoying
  t.verbose = true
end

desc "Generate index"
task "index" do
  system "./bin/indexer"
end

desc "Fetch new mtgjson database"
task "mtgjson:update" do
  system *%W[wget http://mtgjson.com/json/AllSets-x.json -O data/AllSets-x.json]
  Rake::Task["index"].invoke
end

desc "Fetch new mtgjson database"
task "pics:gatherer" do
  require_relative "lib/card_database"
  json_path = Pathname(__dir__) + "data/index.json"
  db = CardDatabase.load(json_path)

  # Pathname("pics").mkpath
  db.printings.each do |c|
    if c.multiverseid
      path = Pathname("pics/#{c.set_code}/#{c.number}.png")
      mirror_path = Pathname("gatherer/#{c.multiverseid}.,png")

      path.parent.mkpath
      if path.exist?
        # OK
      elsif mirror_path.exist?
        FileUtils.cp mirror_path, path
      else
        url = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=#{c.multiverseid}&type=card"
        puts "Downloading #{c.name} #{c.set_code} #{c.multiverseid}"
        system "wget", "-nv", "-nc", url, "-O", path.to_s
      end
    end
  end
end

desc "Clanup Rails files"
task "clean" do
  [
    "frontend/log/development.log",
    "frontend/tmp",
  ].each do |path|
    system "trash", path if Pathname(path).exist?
  end
  Dir["**/.DS_Store"].each do |ds_store|
    FileUtils.rm ds_store
  end
end
