describe "Vanguard" do
  include_context "db", "van"

  it "Vanguard cards" do
    "t:*"            .should equal_search "t:vanguard"
    "layout:vanguard".should equal_search "t:vanguard"
    "sakashima"      .should return_no_cards
    "sakashima t:*"  .should return_cards "Sakashima the Impostor Avatar"
  end
end
