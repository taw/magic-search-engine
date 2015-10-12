require_relative "test_helper"

class CardDatabaseAVRTest < Minitest::Test
  def setup
    @db = load_database("avr")
  end

  def test_mana_x
    assert_search_results "mana>=xw", "Divine Deflection", "Entreat the Angels"
    assert_search_results "mana>xw", "Entreat the Angels"
    assert_search_results "mana>xx", "Entreat the Angels", "Bonfire of the Damned"
    assert_search_results "mana>={R}{X}", "Bonfire of the Damned"
  end
end
