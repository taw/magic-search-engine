describe "Alpha" do
  include_context "db"

  it "legality" do
    "e:al f:edh"     .should equal_search "e:al f:commander"
    "e:al legal:edh" .should equal_search "e:al legal:commander"
    "e:al f:legacy"  .should equal_search "e:al -banned:legacy"
    "e:al f:vintage" .should equal_search "e:al -banned:vintage"
    "e:al f:modern"  .should equal_search "e:al legal:modern"
    "e:al f:standard".should equal_search "e:al f:brawl"
  end

  it "reserved" do
    "is:reserved" .should include_cards "Black Lotus"
    "not:reserved".should include_cards "Shivan Dragon"
  end
end
