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
    search(query_string) == []
  end

  failure_message do
    results = search(query_string)
    "Expected `#{query_string}' to have no results, but got following cards:\n" +
      results.map{|c| "* #{c}\n"}.join
  end
end

RSpec::Matchers.define :equal_search do |query_string2|
  match do |query_string1|
    results1 = search(query_string1)
    results2 = search(query_string2)
    results1 == results2 and results1 != []
  end

  failure_message do
    results1 = search(query_string1)
    results2 = search(query_string2)
    if results1 != results2
      "Expected `#{query_string1}' and `#{query_string2}' to return same results"
    else results1 == []
      "Test is unreliable because results are empty: #{query_string1}"
    end
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
