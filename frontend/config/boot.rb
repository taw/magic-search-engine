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
