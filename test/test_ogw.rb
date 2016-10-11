require_relative "test_helper"

class CardDatabaseOathGatewatchTest < Minitest::Test
  def setup
    @db = load_database("ogw")
  end

  def test_colorless_mana_is_not_generic_mana
    card_6  = @db.cards["kozilek's pathfinder"]
    card_5c = @db.cards["endbringer"]

    assert ConditionMana.new("=", "6").match?(card_6)
    refute ConditionMana.new("=", "6").match?(card_5c)
    refute ConditionMana.new("=", "5{c}").match?(card_6)
    assert ConditionMana.new("=", "5{c}").match?(card_5c)
  end

  def test_devoid_doesnt_affect_color_identity
    assert_equal @db.cards["abstruse interference"].color_identity, "u"
    assert_search_include "ci:u", "Abstruse Interference"
    assert_search_exclude "ci:c", "Abstruse Interference"
  end
end
