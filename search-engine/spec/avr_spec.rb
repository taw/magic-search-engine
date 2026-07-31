describe "Avacyn Restored" do
  include_context "db", "avr"

  it "mana_x" do
    assert_search_results "mana>=xw", "Divine Deflection", "Entreat the Angels"
    assert_search_results "mana>xw", "Entreat the Angels"
    assert_search_results "mana>xx", "Entreat the Angels", "Bonfire of the Damned"
    assert_search_results "mana>={R}{X}", "Bonfire of the Damned"
  end
end
