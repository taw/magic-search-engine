require_relative "test_helper"

class CardDatabaseVanguardTest < Minitest::Test
  def setup
    @db = load_database("van")
  end

  def test_vanguard
    assert_search_equal "t:*", "t:vanguard"
    assert_search_equal "layout:vanguard", "t:vanguard"
    assert_search_results "sakashima"
    assert_search_results "sakashima t:*", "Sakashima the Impostor Avatar"
  end
end
