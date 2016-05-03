require_relative "test_helper"

class CardDatabaseOriginsTest < Minitest::Test
  def setup
    @db = load_database("ori")
  end

  def test_other
    assert_search_results "other:cmc=3", "Chandra, Roaring Flame", "Liliana, Defiant Necromancer", "Nissa, Sage Animist"
    assert_search_results "other:(a:eric)", "Chandra, Fire of Kaladesh", "Chandra, Roaring Flame"
  end
end
