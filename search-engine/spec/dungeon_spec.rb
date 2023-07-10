describe "Dungeons" do
  include_context "db", "afr", "tafr"

  it "t:dungeon" do
    assert_search_results "t:dungeon",
      "Dungeon of the Mad Mage",
      "Lost Mine of Phandelver",
      "Tomb of Annihilation"
  end

  it "layout:dungeon" do
    assert_search_equal "t:dungeon", "layout:dungeon"
    assert_search_equal "t:dungeon", "is:dungeon"
  end

  it "is not paper legal" do
    assert_search_results "t:dungeon is:paper"
    assert_search_results "t:dungeon f:*"
  end
end
