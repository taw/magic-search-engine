require_relative "test_helper"

class CardDatabaseFNMTest < Minitest::Test
  def setup
    @db = load_database("fnmp")
  end

  def test_year
    assert_count_results "year = 2000", 11
    assert_count_results "year < 2003", 30
    assert_search_equal "year > 2004", "year >= 2005 "
  end
end
