require_relative "test_helper"

class CardDatabaseOriginsTest < Minitest::Test
  def setup
    @db = load_database("ori")
  end

  def test_other
    assert_search_results "other:cmc=3", "Chandra, Fire of Kaladesh", "Chandra, Roaring Flame", "Liliana, Defiant Necromancer", "Liliana, Heretical Healer", "Nissa, Sage Animist", "Nissa, Vastwood Seer"
    assert_search_results "other:(a:eric)", "Chandra, Fire of Kaladesh", "Chandra, Roaring Flame"
  end
end
