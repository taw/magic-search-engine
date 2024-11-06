describe "Alchemy" do
  include_context "db"

  # Their numbers are all conveniently "A-" so no special logic needed
  it "no Alchemy cards in any baseset" do
    assert_search_results "is:alchemy is:baseset"
  end

  it "no Alchemy cards in any boosters" do
    assert_search_results "is:alchemy booster:*"
  end

  it "no Alchemy cards in any precons (except Arena precons)" do
    assert_search_results 'is:alchemy deck:* -deck:"Collateral Damage" -deck:"Lightly Armored" -deck:"Braaains" -deck:"Ancient Discovery"'
  end

  it "has:alchemy and is:alchemy returns same number of cards" do
    search_names("has:alchemy").size.should == search_names("is:alchemy").size
  end
end
