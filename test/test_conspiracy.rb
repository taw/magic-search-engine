require_relative "test_helper"

class CardDatabaseConspiracyTest < Minitest::Test
  def setup
    @db = load_database("cns")
  end

  def test_conspiracy
    assert_search_results 't:conspiracy o:"one mana of any color"', "Secrets of Paradise", "Worldknit"
  end

  def test_conspiracy_cards_not_included_unless_requested
    assert_search_results 'o:"one mana of any color"', "Mirrodin's Core", "Spectral Searchlight"
  end

  def test_bang_search_doesnt_require_explicit_flags
    assert_search_results "!Secrets of Paradise", "Secrets of Paradise"
  end
end
