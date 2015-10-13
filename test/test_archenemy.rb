
require_relative "test_helper"

class CardDatabaseArchenemyTest < Minitest::Test
  def setup
    @db = load_database("arc")
  end

  def test_scheme
    assert_search_results 't:scheme o:trample', "Your Will Is Not Your Own", "The Very Soil Shall Shake"
    assert_search_results 't:ongoing o:trample', "The Very Soil Shall Shake"
  end

  def test_scheme_cards_not_included_unless_requested
    assert_search_results "o:trample",
      "Armadillo Cloak",
      "Colossal Might",
      "Kamahl, Fist of Krosa",
      "Molimo, Maro-Sorcerer",
      "Rancor",
      "Scion of Darkness"
  end

  def test_bang_search_doesnt_require_explicit_flags
    assert_search_results "!Your Will Is Not Your Own", "Your Will Is Not Your Own"
  end
end
