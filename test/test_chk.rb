require_relative "test_helper"

class CardDatabaseCHKTest < Minitest::Test
  def setup
    @db = load_database("chk")
  end

  def test_is_split
    assert_search_results "is:split"
    assert_search_results "is:dfc"
    assert_search_include "is:flip", "Akki Lavarunner"
    assert_search_exclude "not:flip", "Akki Lavarunner"
  end
end
