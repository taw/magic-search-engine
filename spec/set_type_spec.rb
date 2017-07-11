describe "Set types" do
  include_context "db"

  it "basic types" do
    assert_search_results "angel of wrath st:ftv", "Akroma, Angel of Wrath"
    assert_search_results "angel of wrath st:dd", "Akroma, Angel of Wrath"
    assert_search_results "angel of wrath st:expansion", "Akroma, Angel of Wrath"
    assert_search_results "armageddon st:masters", "Armageddon", "Armageddon Clock"
    assert_search_results "armageddon st:reprint", "Armageddon"
    assert_search_results "armageddon st:core", "Armageddon", "Armageddon Clock"
    assert_search_results "armageddon st:starter", "Armageddon"
  end

  it "abbreviations" do
    assert_search_equal "st:cmd", "st:commander"
    assert_search_equal "st:ex", "st:expansion"
    assert_search_equal "st:ftv", 'st:"from the vault"'
    assert_search_equal "st:arc", "st:archenemy"
    assert_search_equal "st:cns", "st:conspiracy"
    assert_search_equal "st:dd", 'st:"duel deck"'
    assert_search_equal "st:rep", "st:reprint"
    assert_search_equal "st:me", "st:masters"
    assert_search_equal "st:starter", "st:st"
    assert_search_equal "st:pds", 'st:"premium deck"'
    assert_search_equal "st:pc", "st:planechase"
  end

  it "cm1 exception" do
    "desertion st:fixed".should return_cards "Desertion"
    "desertion st:cmd"  .should return_cards "Desertion"
    "desertion st:deck" .should return_no_cards
  end

  it "starter sets" do
    assert_search_results "alert shu st:booster", "Alert Shu Infantry"
    assert_search_results "knight errant st:fixed", "Knight Errant"
  end
end
