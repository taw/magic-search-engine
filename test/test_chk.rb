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

  def test_is_primary
    assert_search_results "is:primary t:fox",
      "Eight-and-a-Half-Tails",
      "Kitsune Blademaster",
      "Kitsune Diviner",
      "Kitsune Healer",
      "Kitsune Mystic",
      "Kitsune Riftwalker",
      "Pious Kitsune",
      "Samurai of the Pale Curtain",
      "Sensei Golden-Tail"
    assert_search_results "not:primary t:fox",
      "Autumn-Tail, Kitsune Sage"
  end
end
