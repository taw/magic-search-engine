require_relative "test_helper"

class CardDatabaseKLDTest < Minitest::Test
  def setup
    @db = load_database("kld")
  end

  def test_vehicles
    assert_search_results "pow=10", "Demolition Stomper", "Metalwork Colossus"
    assert_search_results "tou=7", "Accomplished Automaton", "Demolition Stomper"
  end

  def test_sort_pow
    assert_search_results_ordered "r:mythic t:artifact sort:pow",
      "Combustible Gearhulk",          # 6
      "Skysovereign, Consul Flagship", # 6 vehicle
      "Noxious Gearhulk",              # 5
      "Torrential Gearhulk",           # 5
      "Cataclysmic Gearhulk",          # 4
      "Verdurous Gearhulk",            # 4
      "Aetherworks Marvel"             # nil
  end

  def test_sort_tou
     assert_search_results_ordered "r:mythic t:artifact sort:tou",
       "Combustible Gearhulk",          # 6
       "Torrential Gearhulk",           # 6
       "Cataclysmic Gearhulk",          # 5
       "Skysovereign, Consul Flagship", # 5 vehicle
       "Noxious Gearhulk",              # 4
       "Verdurous Gearhulk",            # 4
       "Aetherworks Marvel"             # nil
  end
end
