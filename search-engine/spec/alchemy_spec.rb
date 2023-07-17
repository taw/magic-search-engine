describe "Alchemy" do
  include_context "db"

  # Their numbers are all conveniently "A-" so no special logic needed
  it "no Alchemy cards in any baseset" do
    assert_search_results "is:alchemy is:baseset"
  end

  it "no Alchemy cards in any boosters" do
    assert_search_results "is:alchemy booster:*"
  end

  it "no Alchemy cards in any precons" do
    assert_search_results "is:alchemy deck:*"
  end
end
