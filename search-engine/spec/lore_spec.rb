describe "Lore queries" do
  include_context "db"

  it do
    assert_search_equal "lore:gideon", "gideon or t:gideon or ft:gideon"
    assert_search_equal "lore:jaya", "jaya or t:jaya or ft:jaya"
    assert_search_equal "lore:chandra", "chandra or t:chandra or ft:chandra"
    assert_search_equal %[lore:"nicol bolas"], %[lore:"nicol bolas" or t:"nicol bolas" or ft:"nicol bolas"]
  end

  it "passes metadata to subconditions" do
    # subconditions need :fuzzy to suggest spellings, and :logger to report them
    assert_search_equal "lore:jaec beleren", "jaec beleren"
    db.search("lore:jaec beleren").warnings.should include(%[Trying spelling "jace" in addition to "jaec"])
    db.search("lore:jace beleren").warnings.should be_empty
  end
end
