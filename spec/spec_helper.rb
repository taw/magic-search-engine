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

RSpec::Matchers.define :exclude_cards do |*cards|
  match do |query_string|
    results = search(query_string)
    results != [] and cards.none?{|card| results.include?(card)}
  end

  failure_message do
    results = search(query_string)
    fails = cards.select{|card| results.include?(card)}
    if fails != []
      "Expected `#{query_string}' to exclude following cards:\n" +
        fails.map{|c| "* #{c}\n"}.join
    else
      "Test is unreliable because results are empty: #{query_string1}"
    end
  end
end

RSpec::Matchers.define :return_no_cards do
  match do |query_string|
    search(query_string) == []
  end

  failure_message do
    results = search(query_string)
    "Expected `#{query_string}' to have no results, but got following cards:\n" +
      results.map{|c| "* #{c}\n"}.join
  end
end

RSpec::Matchers.define :return_cards do |*cards|
  match do |query_string|
    search(query_string).sort == cards.sort
  end

  # TODO: Better error message here
  failure_message do
    results = search(query_string)
    "Expected `#{query_string}' to return:\n" +
      cards.map{|c| "* #{c}\n"}.join +
    "Instead got:" +
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
    else
      "Test is unreliable because results are empty: #{query_string1}"
    end
  end
end

RSpec::Matchers.define :have_result_count do |count|
  match do |query_string|
    search(query_string).size == count
  end

  failure_message do
    "Expected `#{query_string}' to return #{count} results, got #{search(query_string).size} instead."
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
