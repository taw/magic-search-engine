require "pathname"
require "fileutils"

def db
  @db ||= begin
    require_relative "search-engine/lib/card_database"
    CardDatabase.load
  end
end

task "default" => "spec"
task "test" => "spec"

# Run specs
task "spec" do
  Dir.chdir("search-engine") do
    sh "rspec"
  end
  Dir.chdir("frontend") do
    sh "rake test"
  end
end

desc "Generate index"
task "index" do
  sh "./indexer/bin/indexer"
end

desc "Fetch new mtgjson database"
task "mtgjson:fetch" do
  sh "indexer/bin/split_mtgjson", "http://mtgjson.com/json/AllSets-x.json"
  sh "./bin/patch-mtg-json"
end

desc "Fetch new mtgjson database, then revert known bad ones"
task "mtgjson:fetch:good" do
  sh "indexer/bin/split_mtgjson", "http://mtgjson.com/json/AllSets-x.json"
  # Unsets and Kamigawa block are broken, mostly flip/split cards
  # CP2 has long uncorrected typo
  # V17 has duplicate Brisela
  # Starter 2000 is technically not broken, but it's annoying how they changed numbers
  sh "git checkout data/sets/{UGL,UNH,UST,CHK,BOK,SOK,V17,S00,CP2}.json"
end

desc "Fetch new mtgjson database and update index"
task "mtgjson:update" => ["mtgjson:fetch:good", "index"]

desc "Update penny dreadful banlist"
task "pennydreadful:update" do
  system "wget -q http://pdmtgo.com/legal_cards.txt -O index/penny_dreadful_legal_cards.txt"
end

desc "Fetch Gatherer pics"
task "pics:gatherer" do
  pics = Pathname("frontend/public/cards")
  db.printings.each do |c|
    next unless c.multiverseid
    path = pics + Pathname("#{c.set_code}/#{c.number}.png")
    path.parent.mkpath
    next if path.exist?
    url = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=#{c.multiverseid}&type=card"
    puts "Downloading #{c.name} #{c.set_code} #{c.multiverseid}"
    system "wget", "-nv", "-nc", url, "-O", path.to_s
  end
end

desc "Connect links to HQ pics"
task "link:pics" do
  Pathname("frontend/public/cards_hq").mkpath
  if ENV["RAILS_ENV"] == "production"
    sources = Dir["/home/rails/magic-card-pics-hq-*/*/"]
  else
    sources = Dir["#{ENV['HOME']}/github/magic-card-pics-hq-*/*/"]
  end
  sources.each do |source|
    source = Pathname(source)
    set_name = source.basename.to_s
    target_path = Pathname("frontend/public/cards_hq/#{set_name}")
    next if target_path.exist?
    # p [target_path, source]
    target_path.make_symlink(source)
  end
end

desc "Fetch HQ pics"
task "pics:hq" do
  sh "./bin/fetch_hq_pics"
end

desc "Print basic statistics about card pictures"
task "pics:statistics" do
  sh "./bin/pics_statistics"
end

desc "Clanup Rails files"
task "clean" do
  [
    "frontend/log/test.log",
    "frontend/log/development.log",
    "frontend/log/production.log",
    "frontend/tmp",
    "frontend/Gemfile.lock",
    "search-engine/Gemfile.lock",
    "search-engine/coverage"
  ].each do |path|
    system "trash", path if Pathname(path).exist?
  end
  Dir["**/.DS_Store"].each do |ds_store|
    FileUtils.rm ds_store
  end
end

desc "Fetch new Comprehensive Rules"
task "rules:update" do
  sh "bin/fetch_comp_rules"
  sh "bin/patch-comp-rules"
  sh "bin/format_comp_rules"
end
