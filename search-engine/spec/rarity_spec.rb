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

  it "short aliases" do
    assert_search_equal "r:b", "r:basic"
    assert_search_equal "r:l", "r:basic"
    assert_search_equal "r:c", "r:common"
    assert_search_equal "r:u", "r:uncommon"
    assert_search_equal "r:r", "r:rare"
    assert_search_equal "r:m", "r:mythic"
    assert_search_equal "r:s", "r:special"
  end
end
