ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# This should maybe be moved to a gem?
require_relative "../../search-engine/lib/card_database"
t0 = Time.now
$CardDatabase = CardDatabase.load
# Preload it
$CardDatabase.supported_booster_types
dt = Time.now - t0
puts "Loading database took: #{dt.round(2)}s"

public_root = Pathname(__dir__) +  "../public"
$CardDatabase.printings.each do |card|
  path_hq = "cards_hq/#{card.set_code}/#{card.number}.png"
  path_lq = "cards/#{card.set_code}/#{card.number}.png"
  if (public_root + path_hq).exist?
    card.image_path = "/#{path_hq}"
  elsif (public_root + path_lq).exist?
    card.image_path = "/#{path_lq}"
  end
end
