require_relative "test_helper"

class CardDatabaseTest < Minitest::Test
  def setup
    @db = CardDatabase.new("data/m10.json")
  end

  def assert_search_results(query, *cards)
    results = @db.search(query)
    assert_equal cards, @db.search(query)
  end

  def assert_search_include(query, *cards)
    results = @db.search(query)
    cards.each do |card|
      assert_includes @db.search(query), card
    end
  end

  def assert_search_exclude(query, *cards)
    results = @db.search(query)
    cards.each do |card|
      assert_excludes @db.search(query), card
    end
  end

  def assert_search_equal(query1, query2)
    results1 = @db.search(query1)
    results2 = @db.search(query2)
    assert_equal results1, results2, "Queries `#{query1}' and `#{query2}' should return same results"
    assert result1.size > 0, "This test is unreliable if results are empty"
  end

  def test_db_loads_and_contains_sets
    assert_instance_of Hash, @m10.data
    assert_equal ["M10"], @m10.data.keys
  end

  def test_search_full_name
    assert_search_results "!Ponder", "Ponder"
    assert_search_results "!ponder", "ponder"
  end

  def test_search_basic
    assert_search_results "Ponder", "Ponder"
    assert_search_results "Wall", "Wall of Bone", "Wall of Faith", "Wall of Fire", "Wall of Frost"
  end

  def test_filter_colors
    assert_search_include "c:b", "Ponder"
    assert_search_include "c!b", "Ponder"
    assert_search_include "c:bu", "Ponder"
    assert_search_exclude "c:g", "Ponder"
    assert_search_exclude "c!bu", "Ponder"
    assert_search_exclude "c:m", "Ponder"
  end

  def test_filter_type
    assert_search_results "t:Skeleton", "Drudge Skeletons", "Wall of Bone"
    assert_search_results "t:Basic", "Forest", "Island", "Mountain", "Plains", "Swamp"
    assert_search_include "t:Sorcery", "Act of Treason"
    assert_search_include "t:Jace", "Jace Beleren"
  end

  def test_queries_are_case_insensitive
    assert_search_equal "t:Sorcery", "t:sorcery"
    assert_search_equal "c:b", "c:B"
    assert_search_equal "c:b", "C:B"
  end
end
