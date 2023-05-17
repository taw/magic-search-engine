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

task "spec" do
  Dir.chdir("search-engine") do
    sh "rspec"
  end
  Dir.chdir("frontend") do
    sh "rspec"
  end
end

desc "Generate index"
task "index" do
  sh "rescue ./indexer/bin/indexer"
  sh "rescue ./booster_indexer/bin/booster_indexer"
end

desc "Update mtgjson database"
task "mtgjson:fetch" do
  unless Pathname("tmp/AllSets.json").exist?
    Pathname("tmp").mkpath
    sh "wget", "https://mtgjson.com/api/v5/AllPrintings.json", "-O", "tmp/AllSets.json" # v5
  end
  if Pathname("data/sets-incoming").exist?
    sh "trash", "data/sets-incoming"
  end
  sh "./indexer/bin/split_mtgjson", "tmp/AllSets.json", "tmp/sets-incoming"
  sh "./indexer/bin/update_mtgjson_sets"
end

desc "Fetch new mtgjson database and update index"
task "mtgjson:update" => ["mtgjson:fetch", "index"]

desc "Update penny dreadful banlist"
task "pennydreadful:update" do
  system "./bin/fetch_penny_dreadful_banlist"
end

desc "Update XMage card lists"
task "xmage:update" do
  sh "rescue bin/extract_xmage_card_list ~/src/mage"
  sh "./bin/export_xmage_best_card_list ~/github/mtg/data/xmage_cards.txt"
end

desc "Fetch Gatherer pics"
task "pics:gatherer" do
  system "./bin/fetch_gatherer_pics"
end

desc "Connect links to HQ pics"
task "link:pics:hq" do
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

desc "Connect links to LQ pics"
task "link:pics:lq" do
  Pathname("frontend/public/cards").mkpath
  if ENV["RAILS_ENV"] == "production"
    sources = Dir["/home/rails/magic-card-pics-[0-9]/*/"]
  else
    sources = Dir["#{ENV['HOME']}/github/magic-card-pics-[0-9]/*/"]
  end
  sources.each do |source|
    source = Pathname(source)
    set_name = source.basename.to_s
    target_path = Pathname("frontend/public/cards/#{set_name}")
    next if target_path.exist?
    # p [target_path, source]
    target_path.make_symlink(source)
  end
end

desc "Connect links to pics"
task "link:pics" => ["link:pics:lq", "link:pics:hq"]

desc "Fetch HQ pics"
task "pics:hq" do
  sh "./bin/fetch_hq_pics"
end

desc "Save HQ pics hashes"
task "pics:hq:save" do
  sh "./bin/save_hq_pics_hashes"
end

desc "Print basic statistics about card pictures"
task "pics:statistics" do
  sh "./bin/pics_statistics"
end

desc "List cards without pictures"
task "pics:missing" do
  sh "./bin/cards_without_pics"
end

desc "List cards with pictures in incorrect orientation"
task "pics:missing" do
  sh "./bin/cards_with_wrong_orientation"
end

desc "List cards with duplicated pictures (except where valid)"
task "pics:dup" do
  sh "./bin/cards_with_dup_pics"
end

desc "Clanup Rails files"
task "clean" do
  [
    "frontend/Gemfile.lock",
    "frontend/log/development.log",
    "frontend/log/production.log",
    "frontend/log/test.log",
    "frontend/tmp",
    "search-engine/.respec_failures",
    "search-engine/coverage",
    "search-engine/Gemfile.lock",
    "tmp",
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

desc "Full update"
task "update" do
  Pathname("tmp").mkpath
  Rake::Task["rules:update"].invoke
  Rake::Task["pennydreadful:update"].invoke
  Rake::Task["mtgjson:fetch"].invoke
  Rake::Task["import:decks"].invoke
  Rake::Task["index"].invoke
  Rake::Task["xmage:update"].invoke
  Rake::Task["update:sealed"].invoke
  Rake::Task["export:decks"].invoke
end

desc "Import deck data"
task "import:decks" do
  sh "~/github/magic-preconstructed-decks/bin/build_jsons ./data/decks.json"
end

desc "Export deck data"
task "export:decks" do
  sh "./bin/export_decks_data_old ~/github/magic-preconstructed-decks-data/decks.json"
  sh "./bin/export_decks_data ~/github/magic-preconstructed-decks-data/decks_v2.json"
end

desc "Update sealed only"
task "update:sealed" do
  sh "./bin/export_sealed_data ~/github/magic-sealed-data"
end

desc "Export decklists as text"
task "decks:export:text" do
  sh "./bin/export_decks_data_text"
end

desc "Run Rails frontend, localhost only"
task "rails:localhost" do
  Dir.chdir("frontend") do
    sh "bundle exec rails server"
  end
end

desc "Run Rails frontend, local network"
task "rails" do
  Dir.chdir("frontend") do
    sh "bundle exec rails server -b 0.0.0.0"
  end
end

desc "Run pry with database loaded"
task "pry" do
  sh "./search-engine/bin/pry_cards"
end

desc "Run all tests"
task "test" do
  Dir.chdir("search-engine") do
    sh "rspec"
  end

  Dir.chdir("frontend") do
    sh "rspec"
  end
end
