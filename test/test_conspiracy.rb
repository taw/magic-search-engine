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

  def test_tstar
    assert_search_equal "t:* t:creature", "t:creature"
    assert_search_equal "t:* t:conspiracy", "t:conspiracy"
    assert_count_results "e:cns", 197
    assert_count_results "t:* e:cns", 210
  end
end
