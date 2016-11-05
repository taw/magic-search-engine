require_relative "../lib/card_database"
require_relative "../lib/cli_frontend"
require "pry"

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = :should
  end
end

RSpec::Matchers.define :include_cards do |*cards|
  match do |query_string|
    results = search(query_string)
    cards.all?{|card| results.include?(card)}
  end

  failure_message do
    results = search(query_string)
    fails = cards.reject{|card| results.include?(card)}
    "Expected `#{query_string}' to include following cards:\n" +
      fails.map{|c| "* #{c}\n"}.join
  end
end

RSpec::Matchers.define :return_no_cards do |*cards|
  match do |query_string|
    results = search(query_string)
    results == []
  end

  failure_message do
    results = search(query_string)
    "Expected `#{query_string}' to have no results, but got following cards:\n" +
      results.map{|c| "* #{c}\n"}.join
  end
end

shared_context "db" do |*sets|
  def load_database(*sets)
    $card_database ||= {}
    $card_database[[]]   ||= CardDatabase.load(Pathname(__dir__) + "../data/index.json")
    $card_database[sets] ||= $card_database[[]].subset(sets)
  end

  def search(query_string)
    Query.new(query_string).search(db).card_names
  end

  let!(:db) { load_database(*sets) }
end
