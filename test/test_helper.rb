require 'minitest/autorun'
require_relative "../lib/card_database"

class Minitest::Test
  # minitest is shitty and doesn't report test results in ordered way
  # because of some ridiculous fetishization of what was basically a workaround
  # for fucking mysql 3 in rails 1
  #
  # randomized *reporting* of results is just going full retard,
  # regardless of which order they're ran in - which should be predictable
  # unless you're still running mysql 3 or some other nontransactional nonsense
  def self.test_order
    :alpha
  end

  def assert_search_results(query_string, *cards)
    query = Query.new(query_string)
    results = @db.search_card_names(query)
    assert_equal cards.sort, results.sort, "Search for #{query_string} (#{query})"
  end

  def assert_search_results_printings(query_string, *card_printings)
    query = Query.new(query_string)
    results = @db.search(query)
    expected = card_printings.map{|name, *sets| [name, *sets.sort]}
    actual   = results.group_by(&:name).map{|name, cards| [name, *cards.map(&:set_code).sort]}
    assert_equal expected, actual, "Search for #{query_string} (#{query})"
  end

  def assert_count_results(query_string, count)
    query = Query.new(query_string)
    results = @db.search_card_names(query)
    assert_equal count, results.size, "Search for #{query_string} (#{query})"
  end

  def assert_search_include(query_string, *cards)
    query = Query.new(query_string)
    results = @db.search_card_names(query)
    cards.each do |card|
      assert_includes results, card, "Search for #{query_string} (#{query})"
    end
  end

  def assert_search_exclude(query_string, *cards)
    query = Query.new(query_string)
    results = @db.search_card_names(query)
    cards.each do |card|
      refute_includes results, card, "Search for #{query_string} (#{query})"
    end
  end

  def assert_search_equal(query_string1, query_string2)
    query1 = Query.new(query_string1)
    query2 = Query.new(query_string2)
    results1 = @db.search_card_names(query1)
    results2 = @db.search_card_names(query2)
    assert_equal results1, results2, "Queries `#{query1}' and `#{query2}' should return same results"
    assert results1.size > 0, "This test is unreliable if results are empty: #{query1}"
  end

  def assert_search_differ(query_string1, query_string2)
    query1 = Query.new(query_string1)
    query2 = Query.new(query_string2)
    results1 = @db.search_card_names(query1)
    results2 = @db.search_card_names(query2)
    refute_equal results1, results2, "Queries `#{query1}' and `#{query2}' should not return same results"
    assert results1.size > 0, "This test is unreliable if results are empty: #{query1}"
    assert results2.size > 0, "This test is unreliable if results are empty: #{query2}"
  end

  def load_database(*sets)
    # Cache for test performance
    $card_database ||= {}
    $card_database[[]]   ||= CardDatabase.load(Pathname(__dir__) + "../data/index.json")
    $card_database[sets] ||= $card_database[[]].subset(sets)
  end
end
