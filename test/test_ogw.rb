require_relative "test_helper"

class CardDatabaseOathGatewatchTest < Minitest::Test
  def setup
    # Not released yet, so we mock things here instead
    # @db = load_database("ogw")
  end

  def test_colorless_mana_is_not_generic_mana
    assert ConditionMana.new("=", "10").match?(OpenStruct.new(mana_cost: "{10}"))
    refute ConditionMana.new("=", "10").match?(OpenStruct.new(mana_cost: "{8}{c}{c}"))
    refute ConditionMana.new("=", "8{c}{c}").match?(OpenStruct.new(mana_cost: "{10}"))
    assert ConditionMana.new("=", "8{c}{c}").match?(OpenStruct.new(mana_cost: "{8}{c}{c}"))
  end
end
