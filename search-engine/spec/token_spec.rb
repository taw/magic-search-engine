describe "Tokens" do
  include_context "db"

  it "is:token" do
    assert_search_results "is:token",
      "Dungeon of the Mad Mage",
      "Lost Mine of Phandelver",
      "The Initiative",
      "The Ring Tempts You",
      "The Ring",
      "Tomb of Annihilation",
      "Undercity"
  end

  it "layout" do
    assert_search_equal "is:token", "is:token (layout:dungeon or layout:token)"
  end

  it "is not paper legal" do
    assert_search_results "is:token is:paper"
    assert_search_results "is:token f:*"
  end

  it "is:card" do
    assert_search_equal "is:card", "not:token"
  end

  # it's nonsense in source data
  it "nothing is t:card" do
    assert_search_results "t:card"
  end
end
