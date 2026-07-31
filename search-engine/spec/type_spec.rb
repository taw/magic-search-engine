describe "Type expr" do
  include_context "db"

  it "=" do
    assert_search_results "t=creature",
      "Nameless Race"
    assert_search_results 't="basic land"',
      "Wastes"
    assert_search_results 't="land forest"',
      "Gingerbread Cabin",
      "Murmuring Bosk",
      "Sapseep Forest"
    assert_search_results 't="creature elf" e:8ed',
      "Elvish Champion",
      "Elvish Lyrist",
      "Elvish Scrapper",
      "Gaea's Herald"
  end

  it ">= is :" do
    assert_search_equal "t:elf", 't>=elf'
  end

  it ">= is > or =" do
    assert_search_equal 't>"creature elf"', 't>="creature elf" -t="creature elf"'
  end

  # I don't really need many uses for <= and <
  # These are mostly for completeness
  # You can maybe do some weird OR with it

  it "<" do
    assert_search_results 't<="basic land forest mountain" t:basic',
      "Forest",
      "Mountain",
      "Wastes"
    assert_search_results 't<"basic land forest mountain" t>land',
      "Cinder Glade",
      "Commercial District",
      "Dwarven Mine",
      "Forest",
      "Gingerbread Cabin",
      "Madblind Mountain",
      "Mountain",
      "Murmuring Bosk",
      "Sapseep Forest",
      "Sheltered Thicket",
      "Stomping Ground",
      "Taiga",
      "The Lonely Mountain",
      "Wastes",
      "Wooded Ridgeline"
  end

  it "Kindred and Tribal" do
    assert_search_equal "t:tribal", "t:kindred"
  end

  # Party members are creatures only, outlaws can be any card with those creature types
  it "is:party" do
    assert_search_equal "is:party",
      "t:creature (t:cleric or t:rogue or t:warrior or t:wizard or keyword:changeling)"
    assert_search_include "is:party",
      "Dark Confidant",
      "Woodland Changeling"
    assert_search_exclude "is:party",
      "Cloak and Dagger",
      "Grizzly Bears",
      "Ragavan, Nimble Pilferer",
      "Serra Angel"
  end

  it "is:outlaw" do
    assert_search_equal "is:outlaw",
      "t:assassin or t:mercenary or t:pirate or t:rogue or t:warlock or keyword:changeling"
    assert_search_include "is:outlaw",
      "Cloak and Dagger",
      "Nameless Inversion",
      "Notorious Throng",
      "Ragavan, Nimble Pilferer",
      "Royal Assassin",
      "Woodland Changeling"
    assert_search_exclude "is:outlaw",
      "Dark Confidant",
      "Grizzly Bears",
      "Prophetic Prism"
  end

  # Rogues and changelings are both, and so is anything like a Pirate Warrior
  it "is:party and is:outlaw overlap" do
    assert_search_include "is:party is:outlaw",
      "Siren Stormtamer",
      "Woodland Changeling",
      "Zulaport Cutthroat"
    assert_search_equal "is:party is:outlaw -t:rogue -keyword:changeling",
      "t:creature (t:cleric or t:warrior or t:wizard) (t:assassin or t:mercenary or t:pirate or t:warlock) -t:rogue -keyword:changeling"
  end

  it "is:basictype" do
    assert_search_equal "is:basictype", "t:plains or t:island or t:swamp or t:mountain or t:forest"
  end

  it "is:historic" do
    assert_search_equal "is:historic", "t:artifact or t:legendary or t:saga"
  end

  context "8th Edition" do
    include_context "db", "8ed"

    it "type line apostrophe" do
      "Urza’s"  .should include_cards "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
      "Urza’s"  .should include_cards "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
      "urza's"  .should include_cards "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
      "urza"    .should include_cards "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
      "o:Urza’s".should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
      "o:urza's".should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
      "o:urza"  .should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
      "t:Urza’s".should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
      "t:urza's".should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
      "t:urza"  .should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    end

    it "type line hyphen" do
      "t:power-plant"         .should include_cards "Urza's Power Plant"
      "t:power\u2212plant"    .should include_cards "Urza's Power Plant"
      't:"power plant"'       .should return_no_cards
      't:"power-plant"'       .should include_cards "Urza's Power Plant"
      %[t:"power\u2212plant"].should include_cards "Urza's Power Plant"
      "o:power-plant"         .should include_cards "Urza's Mine", "Urza's Tower"
      "o:power\u2212plant"    .should include_cards "Urza's Mine", "Urza's Tower"
      'o:"power plant"'       .should return_no_cards
      'o:"power-plant"'       .should include_cards "Urza's Mine", "Urza's Tower"
      %[o:"power\u2212plant"].should include_cards "Urza's Mine", "Urza's Tower"
    end
  end
end
