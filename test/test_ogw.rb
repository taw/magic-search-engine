require_relative "test_helper"

class CardDatabaseOathGatewatchTest < Minitest::Test
  def setup
    @db = load_database("ogw")
  end

  def test_colorless_mana_is_not_generic_mana
    assert ConditionMana.new("=", "10").match?(OpenStruct.new(mana_cost: "{10}"))
    refute ConditionMana.new("=", "10").match?(OpenStruct.new(mana_cost: "{8}{c}{c}"))
    refute ConditionMana.new("=", "8{c}{c}").match?(OpenStruct.new(mana_cost: "{10}"))
    assert ConditionMana.new("=", "8{c}{c}").match?(OpenStruct.new(mana_cost: "{8}{c}{c}"))
  end

  def test_devoid_doesnt_affect_color_identity
    assert_equal @db.cards["Abstruse Interference"].color_identity, "u"
    assert_search_include "ci:u", "Abstruse Interference"
    assert_search_exclude "ci:c", "Abstruse Interference"
  end
end
