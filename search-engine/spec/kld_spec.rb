describe "Kaladesh" do
  include_context "db", "kld"

  it "vehicles" do
    assert_search_results "pow=10", "Demolition Stomper", "Metalwork Colossus"
    assert_search_results "tou=7", "Accomplished Automaton", "Demolition Stomper"
  end
end
