ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# This should maybe be moved to a gem?
require_relative "../../lib/card_database"
$CardDatabase = CardDatabase.load(Pathname(__dir__) + "../../data/index.json")
