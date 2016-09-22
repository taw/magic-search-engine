require_relative "test_helper"

class CardDatabaseKLDTest < Minitest::Test
  def setup
    @db = load_database("kld")
  end

  def test_vehicles
    assert_search_results "pow=10", "Demolition Stomper", "Metalwork Colossus"
    assert_search_results "tou=7", "Accomplished Automaton", "Demolition Stomper"
  end
end
