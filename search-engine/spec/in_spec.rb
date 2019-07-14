describe "in queries" do
  include_context "db"

  it "in:paper" do
    assert_search_equal "in:paper", "alt:game:paper"
  end

  it "in:mtgo" do
    assert_search_equal "in:mtgo", "alt:game:mtgo"
  end

  it "in:arena" do
    assert_search_equal "in:arena", "alt:game:arena"
  end

  it "in:booster" do
    assert_search_equal "in:booster", "alt:is:booster"
  end

  it "in:foil" do
    assert_search_equal "in:foil", "alt:in:foil"
  end

  it "in:nonfoil" do
    assert_search_equal "in:nonfoil", "alt:in:nonfoil"
  end

  it "in:rarity" do
    assert_search_equal "in:basic", "alt:r:basic"
    assert_search_equal "in:common", "alt:r:common"
    assert_search_equal "in:uncommon", "alt:r:uncommon"
    assert_search_equal "in:rare", "alt:r:rare"
    assert_search_equal "in:mythic", "alt:r:mythic"
    assert_search_equal "in:special", "alt:r:special"
  end

  it "in: edition" do
    assert_search_equal "in:lea in:m10", "alt:e:lea alt:e:m10"
    assert_search_equal "in:zendikar in:commander", "alt:e:zendikar alt:e:commander"
    assert_search_equal "in:commander,m10,m11,m12", "alt:e:commander or alt:e:m10 or alt:e:m11 or alt:e:m12"
  end
end
