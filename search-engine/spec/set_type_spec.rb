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
    assert_search_equal "st:standard", "(st:core or st:expansion or e:w16,w17)"
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

  # mtgjson follows some but not all of them
  it "scryfall types" do
    "st:commander".should return_some_cards
    "st:core".should include_search "e:lea,leb,2ed,3ed,4ed,5ed,6ed,7ed,8ed,9ed,10e,m10,m11,m12,m13,m14,m15,m19,m20"
    "st:expansion".should return_some_cards
    "st:masterpiece".should return_some_cards
    "st:masters".should return_some_cards
    "st:multiplayer".should return_some_cards
  end
end
