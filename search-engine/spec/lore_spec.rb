describe "Lore queries" do
  include_context "db"

  it do
    assert_search_equal "lore:gideon", "gideon or t:gideon or ft:gideon"
    assert_search_equal "lore:jaya", "jaya or t:jaya or ft:jaya"
    assert_search_equal "lore:chandra", "chandra or t:chandra or ft:chandra"
    assert_search_equal %Q[lore:"nicol bolas"], %Q[lore:"nicol bolas" or t:"nicol bolas" or ft:"nicol bolas"]
  end
end
