require_relative "test_helper"

class CardDatabaseFullTest < Minitest::Test
  def setup
    @db = load_database
  end

  def test_stats
    assert_equal 15396, @db.cards.size
    assert_equal 29146, @db.printings.size
  end
end
