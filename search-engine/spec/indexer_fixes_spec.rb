describe "Indexer Fixes Test" do
  include_context "db"

  it "rqs" do
    %W[basic common uncommon rare].each do |rarity|
      (search("e:rqs r:#[rarity}") - search("e:4e r:#[rarity}")).should be_empty
    end
    (search("e:rqs -r:rare -r:uncommon -r:common -r:basic")).should be_empty
  end

  it "itp" do
    %W[basic common uncommon rare].each do |rarity|
      (search("e:rqs r:#[rarity}") - search("e:4e r:#[rarity}")).should be_empty
    end
    (search("e:itp -r:rare -r:uncommon -r:common -r:basic")).should be_empty
  end

  it "Coldsnap Theme Decks" do
    (search("e:cstd -r:uncommon -r:common -r:basic")).should be_empty

    assert_search_results "e:cstd r:common",
      "Aurochs",
      "Barbed Sextant",
      "Brainstorm",
      "Casting of Bones",
      "Dark Banishing",
      "Dark Ritual",
      "Deadly Insect",
      "Disenchant",
      "Essence Flare",
      "Gangrenous Zombies",
      "Gorilla Shaman",
      "Incinerate",
      "Insidious Bookworms",
      "Kjeldoran Dead",
      "Kjeldoran Pride",
      "Lat-Nam's Legacy",
      "Legions of Lim-Dûl",
      "Mistfolk",
      "Orcish Lumberjack",
      "Phantasmal Fiend",
      "Portent",
      "Reinforcements",
      "Snow Devil",
      "Soul Burn",
      "Tinder Wall",
      "Woolly Mammoths",
      "Zuran Spellcaster"

    assert_search_results "e:cstd r:uncommon",
      "Arcum's Weathervane",
      "Ashen Ghoul",
      "Balduvian Dead",
      "Binding Grasp",
      "Bounty of the Hunt",
      "Browse",
      "Death Spark",
      "Drift of the Dead",
      "Giant Trap Door Spider",
      "Iceberg",
      "Kjeldoran Elite Guard",
      "Kjeldoran Home Guard",
      "Orcish Healer",
      "Scars of the Veteran",
      "Skull Catapult",
      "Storm Elemental",
      "Swords to Plowshares",
      "Viscerid Drone",
      "Whalebone Glider",
      "Wings of Aesthir"

    assert_search_results "e:cstd r:basic",
      "Forest",
      "Island",
      "Mountain",
      "Plains",
      "Swamp"
  end

  it "No unknown artists" do
    assert_search_results %Q[a:"?"]
  end

  # Some old issues fixed since then, but extra regression tests won't hurt
  it "No Ae ligature in card names" do
    db.cards.values.map(&:name).grep(/Æ/i).should be_empty
  end

  it "No &amp; in artist names" do
    db.printings.map(&:artist_name).grep(/&amp/).should be_empty
  end
end
