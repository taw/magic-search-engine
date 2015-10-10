require_relative "test_helper"

class CardDatabaseInnistradTest < Minitest::Test
  def setup
    @db = CardDatabase.new(Pathname(__dir__) + "index/isd.json")
  end

  def test_dfc_color_applies_to_side_separately
    assert_search_include "ci:gb", "Garruk Relentless"
    assert_search_include "ci:gb", "Garruk, the Veil-Cursed"
    assert_search_exclude "ci:g", "Garruk Relentless"
    assert_search_exclude "ci:g", "Garruk, the Veil-Cursed"
    assert_search_exclude "ci:b", "Garruk Relentless"
    assert_search_exclude "ci:b", "Garruk, the Veil-Cursed"
    assert_search_include "ci:wb", "Loyal Cathar"
    assert_search_include "ci:wb", "Unhallowed Cathar"
    assert_search_exclude "ci:w", "Loyal Cathar"
    assert_search_exclude "ci:b", "Loyal Cathar"
    assert_search_exclude "ci:w", "Unhallowed Cathar"
    assert_search_exclude "ci:b", "Unhallowed Cathar"
  end

  def test_dfg_color_identity_applies_to_both_sides_together
    assert_search_include "c!g", "Garruk Relentless"
    assert_search_include "c!gb", "Garruk, the Veil-Cursed"
    assert_search_include "c!w", "Loyal Cathar"
    assert_search_include "c!b", "Unhallowed Cathar"
  end
end
