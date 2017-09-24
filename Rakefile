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
end

desc "Fetch new mtgjson database and update index"
task "mtgjson:update" => ["mtgjson:fetch", "index"]

desc "Update penny dreadful banlist"
task "pennydreadful:update" do
  system "wget http://pdmtgo.com/legal_cards.txt -O index/penny_dreadful_legal_cards.txt"
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
  total = Hash.new(0)
  db.printings.each do |card|
    path_lq = Pathname("frontend/public/cards/#{card.set_code}/#{card.number}.png")
    path_hq = Pathname("frontend/public/cards_hq/#{card.set_code}/#{card.number}.png")
    total["all"] += 1
    total["lq"]  += 1 if path_lq.exist?
    total["hq"]  += 1 if path_hq.exist?
  end
  puts "Cards: #{total["all"]}"
  puts "LQ: #{total["lq"]}"
  puts "HQ: #{total["hq"]}"
end

desc "Print detailed statistics about card pictures"
task "pics:statistics:extra" do
  by_set = {}
  db.printings.each do |card|
    set = card.set_code
    path_lq = Pathname("frontend/public/cards/#{card.set_code}/#{card.number}.png")
    path_hq = Pathname("frontend/public/cards_hq/#{card.set_code}/#{card.number}.png")
    by_set[set] ||= Hash.new(0)
    by_set[set]["total"] += 1.0
    if path_hq.exist?
      by_set[set]["hq"] += 1
    elsif path_lq.exist?
      by_set[set]["lq"] += 1
    else
      by_set[set]["none"] += 1
    end
  end
  by_set
    .select{|set_name, stats|
      # Online only sets can't possibly have HQ scans
      if db.sets[set_name].online_only?
        stats["none"] > 0
      else
        stats["lq"] + stats["none"] > 0
      end
    }
    .sort_by{|set_name, stats|
      set = db.sets[set_name]
      [-set.release_date.to_i_sort, set.name]
    }
    .each do |set_name, stats|
    summary = [
      ("#{stats["hq"]} HQ" if stats["hq"] > 0),
      ("#{stats["lq"]} LQ" if stats["lq"] > 0),
      ("#{stats["none"]} No Picture" if stats["none"] > 0),
    ].compact.join(", ")
    puts "#{set_name}: #{summary}"
  end
end

desc "Clanup Rails files"
task "clean" do
  [
    "frontend/log/development.log",
    "frontend/log/test.log",
    "frontend/tmp",
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
  sh "bin/format_comp_rules"
end
