require_relative "test_helper"

class CardDatabaseCHKTest < Minitest::Test
  def setup
    @db = load_database("chk")
  end

  def test_is_split
    assert_search_results "is:split"
    assert_search_results "is:dfc"
    assert_search_include "is:flip", "Akki Lavarunner"
    assert_search_exclude "not:flip", "Akki Lavarunner"
  end

  # 709.1c A flip card’s color and mana cost don’t change if the permanent is flipped. Also, any changes to it by external effects will still apply.
  def test_flip_mana_cost
    assert_search_include "cmc=4", "Kitsune Mystic", "Autumn-Tail, Kitsune Sage"
    assert_search_include "mana=3w", "Kitsune Mystic", "Autumn-Tail, Kitsune Sage"
  end
end
