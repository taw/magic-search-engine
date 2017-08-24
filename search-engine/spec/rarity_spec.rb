describe "Rarity" do
  include_context "db"

  it "r: and r=" do
    assert_search_equal "r:uncommon", "r=uncommon"
  end

  it "r>" do
    assert_search_equal "r>rare", "r:mythic or r:special"
    "r>special".should return_no_cards
  end

  it "r<" do
    assert_search_equal "r<rare", "r:uncommon or r:common or r:basic"
    "r<basic".should return_no_cards
  end

  it "r>=" do
    assert_search_equal "r>=mythic", "r:mythic or r:special"
  end

  it "r<=" do
    assert_search_equal "r<=uncommon", "r:uncommon or r:common or r:basic"
    assert_search_equal "r<=basic", "r:basic"
  end
end
