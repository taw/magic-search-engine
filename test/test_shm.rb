require_relative "test_helper"

class CardDatabaseShadowmoorTest < Minitest::Test
  def setup
    @db = load_database("shm")
  end

  def test_2x_mana
    assert_search_results "mana>={2/b}", "Beseech the Queen", "Reaper King"
  end
end
