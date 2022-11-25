describe "Magic 2010" do
  include_context "db", "m10"

  it "db_loads_and_contains_sets" do
    db.number_of_cards.should eq(234)
    db.number_of_printings.should eq(249)
  end

  it "search_full_name" do
    assert_search_results "!Ponder", "Ponder"
    assert_search_results "!ponder", "Ponder"
    assert_search_results "!acidic slime", "Acidic Slime"
    assert_search_results "!ACIDIC  SLIME ", "Acidic Slime"
    assert_search_results "!Slime Acidic"
    assert_search_results "!Slime"
    assert_search_results "!Acidic"
  end

  it "search_basic" do
    assert_search_results "Ponder", "Ponder"
    assert_search_results "Wall", "Wall of Bone", "Wall of Faith", "Wall of Fire", "Wall of Frost"
    assert_search_results "Wall of", "Wall of Bone", "Wall of Faith", "Wall of Fire", "Wall of Frost"
    assert_search_results "of Wall", "Wall of Bone", "Wall of Faith", "Wall of Fire", "Wall of Frost"
    assert_search_results '"Wall of"', "Wall of Bone", "Wall of Faith", "Wall of Fire", "Wall of Frost"
    assert_search_results '"of Wall"'
    assert_search_results '"of bo"', "Wall of Bone"
  end

  it "filter_colors" do
    assert_search_include "c:u", "Ponder"
    assert_search_include "c!u", "Ponder"
    "c:ub".should return_no_cards
    "c:ucm".should return_no_cards
    assert_search_include "c:c", "Howling Mine"
    assert_search_exclude "c:g", "Ponder"
    "c!bu".should return_no_cards
    "c:m".should return_no_cards
    "c:gcm".should return_no_cards

    # Only true for core sets
    assert_search_equal "c:c", "t:artifact or t:land"
  end

  it "filter_type" do
    assert_search_results "t:Skeleton", "Drudge Skeletons", "Wall of Bone"
    assert_search_results "t:Basic", "Forest", "Island", "Mountain", "Plains", "Swamp"
    assert_search_include "t:Sorcery", "Act of Treason"
    assert_search_include "t:Jace", "Jace Beleren"
    assert_search_results 't:"Basic Land"', "Forest", "Island", "Mountain", "Plains", "Swamp"
  end

  it "queries_are_case_insensitive" do
    assert_search_equal "t:Sorcery", "t:sorcery"
    assert_search_equal "c:b", "c:B"
    assert_search_equal "c:b", "C:B"
    assert_search_equal "c:c", "c!c"
  end

  it "pow" do
    assert_search_results "pow=0 c:g", "Birds of Paradise", "Bramble Creeper", "Protean Hydra"
    assert_search_results "pow>=4 c:u", "Air Elemental", "Djinn of Wishes", "Sphinx Ambassador"
    assert_search_results "pow>4 c:u", "Sphinx Ambassador"
    assert_search_results "pow<=4 c:c", "Ornithopter", "Platinum Angel"
    assert_search_results "pow<4 c:c", "Ornithopter"
    assert_search_results "pow=6", "Ball Lightning", "Capricious Efreet", "Craw Wurm"
    assert_search_results "pow<tou c:r", "Dragon Whelp", "Goblin Artillery", "Stone Giant", "Wall of Fire"
    assert_search_results "pow>cmc c:r", "Ball Lightning", "Jackal Familiar"
  end

  it "tou" do
    assert_search_results "tou<=cmc c:c", "Darksteel Colossus", "Platinum Angel"
    assert_search_results "tou>=9", "Darksteel Colossus", "Kalonian Behemoth"
    assert_search_results "tou>9", "Darksteel Colossus"
  end

  it "cmc" do
    assert_search_results "cmc=0",
      "Dragonskull Summit",
      "Drowned Catacomb",
      "Forest",
      "Gargoyle Castle",
      "Glacial Fortress",
      "Island",
      "Mountain",
      "Ornithopter",
      "Plains",
      "Rootbound Crag",
      "Spellbook",
      "Sunpetal Grove",
      "Swamp",
      "Terramorphic Expanse"
    assert_search_results "cmc>=7 c:r", "Bogardan Hellkite", "Warp World"
    assert_search_results "cmc=7 c:u", "Sphinx Ambassador"
  end

  it "extra_spaces_in_expr" do
    assert_search_equal "cmc>=7", "cmc >= 7"
    assert_search_equal "pow=cmc", "pow = cmc"
    assert_search_equal "tou<3", "tou < 3"
  end

  it "oracle" do
    assert_search_results 'o:Flying r:rare',
      "Birds of Paradise",
      "Djinn of Wishes",
      "Earthquake",
      "Gargoyle Castle",
      "Guardian Seraph",
      "Hypnotic Specter",
      "Magebane Armor",
      "Magma Phoenix",
      "Nightmare",
      "Shivan Dragon"
    assert_search_results 'o:"First strike" c:r',
      "Kindled Fury",
      "Viashino Spearhunter"
    assert_search_results 'o:{T} o:"add one mana of any color"',
      "Birds of Paradise"
  end

  it "oracle ignores remainder text" do
    assert_search_results "c:g o:flying", "Birds of Paradise", "Windstorm"
  end

  it "full oracle keeps remainder text" do
    assert_search_results "c:g fo:flying",
      "Birds of Paradise", # flying
      "Deadly Recluse",    # reach remainder text
      "Giant Spider",      # reach remainder text
      "Windstorm"          # flying
  end

  it "oracle_cardname" do
    assert_search_results 'o:"whenever ~ deals combat damage"', "Lightwielder Paladin", "Sphinx Ambassador"
  end

  it "flavor_text" do
    assert_search_results "ft:chandra", "Inferno Elemental", "Pyroclasm"
    assert_search_results 'ft:only ft:to', "Acolyte of Xathrid", "Griffin Sentinel", "Wall of Faith"
    assert_search_results 'ft:"only to"', "Acolyte of Xathrid"
    assert_search_equal "ft:to", "ft:/\\bto\\b/"
    assert_search_differ "ft:to", "ft:/to/"
  end

  it "artist" do
    assert_search_results "a:argyle", "Hive Mind"
  end

  it "banned" do
    assert_search_results "banned:modern", "Ponder"
    assert_search_results "banned:legacy"
    assert_search_results "banned:vintage"
  end

  it "restricted" do
    assert_search_results "restricted:modern"
    assert_search_results "restricted:legacy"
    assert_search_results "restricted:vintage", "Ponder"
  end

  it "legal" do
    assert_search_exclude "legal:modern", "ponder"
    assert_search_include "legal:legacy", "Ponder"
    assert_search_exclude "legal:vintage", "Ponder"
  end

  it "format" do
    assert_search_equal "legal:modern", "f:modern"
    assert_search_equal "legal:legacy", "f:legacy"
    assert_search_equal "legal:vintage or restricted:vintage", "f:vintage"
  end

  it "rarity" do
    assert_search_results "r:mythic c:c", "Darksteel Colossus", "Platinum Angel"
    assert_search_results "r:rare t:land", "Dragonskull Summit", "Drowned Catacomb", "Gargoyle Castle", "Glacial Fortress", "Rootbound Crag", "Sunpetal Grove"
    assert_search_results "r:uncommon t:equipment", "Gorgon Flail", "Whispersilk Cloak"
    assert_search_results "r:common t:land", "Terramorphic Expanse"
  end

  it "is_permanent" do
    assert_search_results "-is:permanent r:mythic", "Time Warp"
  end

  it "is_opposes_not" do
    assert_search_equal "not:permanent", "-is:permanent"
    assert_search_equal "not:spell", "-is:spell"
    assert_search_results "not:black-bordered"
    assert_search_equal "not:white-bordered", "not:silver-bordered"
  end

  it "is_spell" do
    assert_search_results "e:m10 r:rare ci:c is:spell", "Coat of Arms", "Howling Mine", "Magebane Armor", "Mirror of Fate", "Pithing Needle"
    assert_search_results "e:m10 r:rare ci:c", "Coat of Arms", "Howling Mine", "Magebane Armor", "Mirror of Fate", "Pithing Needle", "Gargoyle Castle"
  end

  it "loyalty" do
    assert_search_results "loyalty=5", "Liliana Vess"
    assert_search_results "loyalty>cmc", "Chandra Nalaar"
    assert_search_results "loyalty<=4", "Ajani Goldmane", "Garruk Wildspeaker", "Jace Beleren"
  end

  it "unicode_hyphen" do
    ascii_hyphen = "-"
    unicode_hyphen = "\u2212"
    assert_search_results %[o:"#{ascii_hyphen}2"],  "Liliana Vess", "Weakness"
    assert_search_results %[o:"#{unicode_hyphen}2"], "Liliana Vess", "Weakness"
    assert_search_results %[o:#{ascii_hyphen}2],  "Liliana Vess", "Weakness"
    assert_search_results %[o:#{unicode_hyphen}2], "Liliana Vess", "Weakness"
  end

  it "mana" do
    assert_search_results "mana>=2RR mana<=6RR",
      "Bogardan Hellkite",
      "Capricious Efreet",
      "Chandra Nalaar",
      "Dragon Whelp",
      "Inferno Elemental",
      "Magma Phoenix",
      "Shivan Dragon",
      "Siege-Gang Commander",
      "Stone Giant"
    assert_search_results "mana=4g",
      "Bountiful Harvest",
      "Bramble Creeper",
      "Stampeding Rhino"
    assert_search_results "mana=0",
      "Ornithopter",
      "Spellbook"
    assert_search_results "mana>=3WW",
      "Baneslayer Angel",
      "Captain of the Watch",
      "Lightwielder Paladin",
      "Open the Vaults",
      "Planar Cleansing",
      "Serra Angel"
    assert_search_results "mana>2WW",
      "Baneslayer Angel",
      "Captain of the Watch",
      "Lightwielder Paladin",
      "Open the Vaults",
      "Planar Cleansing",
      "Serra Angel"
    assert_search_results "mana=11",
      "Darksteel Colossus"
  end

  it "keyword" do
    assert_search_equal "keyword:flying", "o:flying t:creature -(Stone Giant) -(Vampire Nocturnus)"
  end
end
