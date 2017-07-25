require "pathname"
require "fileutils"
require "pp"

def db
  @db ||= begin
    require_relative "search-engine/lib/card_database"
    json_path = Pathname(__dir__) + "index/index.json"
    CardDatabase.load(json_path)
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

desc "Fetch new mtgjson database and generate diffable files"
task "mtgjson:update" do
  sh *%W[indexer/bin/split_mtgjson http://mtgjson.com/json/AllSets-x.json]
  Rake::Task["index"].invoke
end

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
  source_base = Pathname("/Users/taw/Downloads/hq_pics/") # "Full" resolution
  total = Hash.new(0)

  db.sets.each do |set_code, set|
    matching_dirs = source_base.children.select{|d| d.basename.to_s != "Tokens" and d.basename.to_s != "Emblems"}.select(&:directory?).select{|d|
      d.basename.to_s.downcase == set.code.downcase or d.basename.to_s.downcase == set.gatherer_code.downcase
    }
    if matching_dirs.size == 0
      source_dir = nil
      # warn "Set missing: #{set_code}"
    elsif matching_dirs.size == 1
      source_dir = matching_dirs[0]
    else
      require 'pry'; binding.pry
    end

    nth_card = Hash.new(0)

    set.printings.sort_by{|c| [c.number.to_i, c.number] }.each do |card|
      total["all"] += 1
      if source_dir and source_dir.exist?
        total["set_ok"] += 1
      else
        total["set_miss"] += 1
        next
      end

      nth_card[card.name] += 1
      target_path = Pathname("frontend/public/cards_hq/#{card.set_code}/#{card.number}.png")
      next if target_path.exist?

      clean_name = card.name.tr("®", "r").tr(':"?', "")
                       .sub(" (Big Furry Monster)", " ")
                       .sub(" Shows That Players Like Really Long Card Names So We Made this Card to Have the Absolute Longest Card Name Ever Elemental", "")
      candidate_names = [
        "#{clean_name}.jpg",
        "#{clean_name}.full.jpg",
        "#{clean_name}#{nth_card[card.name]}.jpg",
        "#{clean_name}#{nth_card[card.name]}.full.jpg",
        "#{clean_name} [#{nth_card[card.name]}].jpg",
        "#{clean_name} [#{nth_card[card.name]}].full.jpg",
        ("#{card.names.join(" - ")}.full.jpg" if card.names),
        ("#{card.names.reverse.join(" - ")}.full.jpg" if card.names),
        ("#{card.names.join("_")}.full.jpg" if card.names),
        ("#{card.names.reverse.join("_")}.full.jpg" if card.names),
        ("#{card.names.join("-+")}.full.jpg" if card.names),
        ("#{card.names.reverse.join("-+")}.full.jpg" if card.names),
      ].compact
      candidate_names << "Who What When Where Why.full.jpg" if card.names and card.names.size == 5

      match = candidate_names.find{|bn| (source_dir + bn).exist?}

      if match
        total["ok"] += 1
        # puts "Found #{card.set.gatherer_code} - #{card.name}"
        target_path.parent.mkpath
        FileUtils.cp((source_dir+match), target_path)
      else
        total["miss"] += 1
        has_lq = Pathname("frontend/public/cards/#{card.set_code}/#{card.number}.png").exist?
        if has_lq
          warn "LQ only: #{card.set.gatherer_code} - #{card.name}"
        else
          warn "No pic:  #{card.set.gatherer_code} - #{card.name}"
        end
      end
    end
  end
  pp total
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
