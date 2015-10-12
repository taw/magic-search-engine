require_relative "test_helper"

class CardDatabaseInnistradTest < Minitest::Test
  def setup
    @db = load_database("isd", "dka")
  end

  def test_dfg_color_identity_applies_to_both_sides_together
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

  def test_dfc_color_applies_to_side_separately
    assert_search_include "c!g", "Garruk Relentless"
    assert_search_include "c!gb", "Garruk, the Veil-Cursed"
    assert_search_include "c!w", "Loyal Cathar"
    assert_search_include "c!b", "Unhallowed Cathar"
  end

  def test_midword_hyphen
    assert_search_include "Garruk -Veil-Cursed", "Garruk Relentless"
  end

  def test_dfc_search
    assert_search_include "t:Garruk", "Garruk Relentless", "Garruk, the Veil-Cursed"
    assert_search_include "t:Garruk c:g", "Garruk Relentless", "Garruk, the Veil-Cursed"
    assert_search_include "t:Garruk c!g", "Garruk Relentless"
    assert_search_include "t:Garruk c:b", "Garruk, the Veil-Cursed"
    assert_search_include "t:Garruk c:gb", "Garruk, the Veil-Cursed"
    assert_search_include "Garruk", "Garruk Relentless", "Garruk, the Veil-Cursed"
    assert_search_include "Garruk Relentless", "Garruk Relentless"
    assert_search_include "Garruk, the Veil-Cursed", "Garruk, the Veil-Cursed"
    assert_search_results "is:split"
    assert_search_results "is:flip"
    assert_search_include "is:dfc", "Garruk Relentless", "Garruk, the Veil-Cursed"
    assert_search_results "is:dfc t:planeswalker", "Garruk Relentless", "Garruk, the Veil-Cursed"
    assert_search_results "is:dfc t:artifact", "Chalice of Death", "Chalice of Life", "Elbrus, the Binding Blade"
    assert_search_results "is:dfc c:c", "Chalice of Death", "Chalice of Life", "Elbrus, the Binding Blade"
    assert_search_results "is:dfc ci:c", "Chalice of Death", "Chalice of Life"
    assert_search_equal "is:dfc", "layout:dfc"
    assert_search_equal "not:dfc", "-layout:dfc"
  end

  def test_other
    assert_search_results "c!bgm", "Garruk, the Veil-Cursed"
    assert_search_results "other:c!bgm", "Garruk Relentless"
    assert_search_results "other:(o:wolf o:token)", "Garruk Relentless", "Garruk, the Veil-Cursed", "Mayor of Avabruck", "Ravager of the Fells"
    assert_search_results "other:-t:werewolf c:r", "Homicidal Brute"
  end
end
