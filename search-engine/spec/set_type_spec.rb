describe "Set types" do
  include_context "db"

  it "basic types" do
    assert_search_results "angel of wrath st:ftv", "Akroma, Angel of Wrath"
    assert_search_results "angel of wrath st:dd", "Akroma, Angel of Wrath"
    assert_search_results "angel of wrath st:expansion", "Akroma, Angel of Wrath"
    assert_search_results "armageddon st:masters", "Armageddon", "Armageddon Clock"
    assert_search_results "armageddon st:core", "Armageddon", "Armageddon Clock"
    assert_search_results "armageddon st:starter", "Armageddon"
  end

  it "abbreviations" do
    assert_search_equal "st:2hg", 'st:"two-headed giant"'
    assert_search_equal "st:arc", "st:archenemy"
    assert_search_equal "st:cmd", "st:commander"
    assert_search_equal "st:cns", "st:conspiracy"
    assert_search_equal "st:dd", 'st:"duel deck"'
    assert_search_equal "st:ex", "st:expansion"
    assert_search_equal "st:ftv", 'st:"from the vault"'
    assert_search_equal "st:me", "st:masters"
    assert_search_equal "st:pc", "st:planechase"
    assert_search_equal "st:pds", 'st:"premium deck"'
    assert_search_equal "st:st", "st:starter"
    assert_search_equal "st:std", "st:standard"
  end

  it "underscores and capitalization" do
    assert_search_equal "st:duel_deck", 'st:"duel deck"'
    assert_search_equal "st:duel_deck", 'st:"DUEL DECK"'
    assert_search_equal "st:dd", 'st:DD'
  end

  it "composite types" do
    assert_search_equal "st:standard", "(st:core or st:expansion)"
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
