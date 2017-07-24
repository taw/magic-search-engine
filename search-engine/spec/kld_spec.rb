describe "Kaladesh" do
  include_context "db", "kld"

  it "vehicles" do
    assert_search_results "pow=10", "Demolition Stomper", "Metalwork Colossus"
    assert_search_results "tou=7", "Accomplished Automaton", "Demolition Stomper"
  end

  it "sort:pow" do
    assert_search_results_ordered "r:mythic t:artifact sort:pow",
      "Combustible Gearhulk",          # 6
      "Skysovereign, Consul Flagship", # 6 vehicle
      "Noxious Gearhulk",              # 5
      "Torrential Gearhulk",           # 5
      "Cataclysmic Gearhulk",          # 4
      "Verdurous Gearhulk",            # 4
      "Aetherworks Marvel"             # nil
  end

  it "sort:tou" do
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
