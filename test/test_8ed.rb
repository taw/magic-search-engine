require_relative "test_helper"

class CardDatabase8thEditionTest < Minitest::Test
  def setup
    @db = load_database("8e")
  end

  def test_type_line_apostrophe
    assert_search_include "Urza’s", "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    assert_search_include "urza's", "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    assert_search_include "urza", "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    assert_search_include "o:Urza’s", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    assert_search_include "o:urza's", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    assert_search_include "o:urza", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    assert_search_include "t:Urza’s", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    assert_search_include "t:urza's", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    assert_search_include "t:urza", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
  end

  def test_type_line_hyphen
    assert_search_include "t:power-plant", "Urza's Power Plant"
    assert_search_include "t:power\u2212plant", "Urza's Power Plant"
    assert_search_results 't:"power plant"'
    assert_search_include 't:"power-plant"', "Urza's Power Plant"
    assert_search_include %Q[t:"power\u2212plant"], "Urza's Power Plant"
    assert_search_include "o:power-plant", "Urza's Mine", "Urza's Tower"
    assert_search_include "o:power\u2212plant", "Urza's Mine", "Urza's Tower"
    assert_search_results 'o:"power plant"'
    assert_search_include 'o:"power-plant"', "Urza's Mine", "Urza's Tower"
    assert_search_include %Q[o:"power\u2212plant"], "Urza's Mine", "Urza's Tower"
  end
end
