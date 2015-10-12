require 'minitest/autorun'
require_relative "../lib/card_database"

class Minitest::Test
  def assert_search_results(query, *cards)
    results = @db.search_card_names(query)
    assert_equal cards.sort, results.sort, "Search for #{query}"
  end

  def assert_count_results(query, count)
    results = @db.search_card_names(query)
    assert_equal count, results.size, "Search for #{query}"
  end

  def assert_search_include(query, *cards)
    results = @db.search_card_names(query)
    cards.each do |card|
      assert_includes results, card, "Search for #{query}"
    end
  end

  def assert_search_exclude(query, *cards)
    results = @db.search_card_names(query)
    cards.each do |card|
      refute_includes results, card, "Search for #{query}"
    end
  end

  def assert_search_equal(query1, query2)
    results1 = @db.search_card_names(query1)
    results2 = @db.search_card_names(query2)
    assert_equal results1, results2, "Queries `#{query1}' and `#{query2}' should return same results"
    assert results1.size > 0, "This test is unreliable if results are empty: #{query1}"
  end

  def assert_search_differ(query1, query2)
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
