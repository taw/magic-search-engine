require_relative "test_helper"

class CardDatabaseM10Test < Minitest::Test
  def setup
    @db = CardDatabase.new(Pathname(__dir__) + "index/m10.json")
  end

  def test_db_loads_and_contains_sets
    assert_equal 249, @db.cards.size
  end

  def test_search_full_name
    assert_search_results "!Ponder", "Ponder"
    assert_search_results "!ponder", "Ponder"
    assert_search_results "!acidic slime", "Acidic Slime"
    assert_search_results "!ACIDIC  SLIME ", "Acidic Slime"
    assert_search_results "!Slime Acidic"
    assert_search_results "!Slime"
    assert_search_results "!Acidic"
  end

  def test_search_basic
    assert_search_results "Ponder", "Ponder"
    assert_search_results "Wall", "Wall of Bone", "Wall of Faith", "Wall of Fire", "Wall of Frost"
    assert_search_results "Wall of", "Wall of Bone", "Wall of Faith", "Wall of Fire", "Wall of Frost"
    assert_search_results "of Wall", "Wall of Bone", "Wall of Faith", "Wall of Fire", "Wall of Frost"
    assert_search_results '"Wall of"', "Wall of Bone", "Wall of Faith", "Wall of Fire", "Wall of Frost"
    assert_search_results '"of Wall"'
    assert_search_results '"of bo"', "Wall of Bone"
  end

  def test_filter_colors
    assert_search_include "c:u", "Ponder"
    assert_search_include "c!u", "Ponder"
    assert_search_include "c:ub", "Ponder"
    assert_search_include "c:ucm", "Ponder"
    assert_search_include "c:c", "Howling Mine"
    assert_search_exclude "c:g", "Ponder"
    assert_search_include "c!bu", "Ponder"
    assert_search_exclude "c:m", "Ponder"
    assert_search_exclude "c:gcm", "Ponder"

    # Only true for core sets
    assert_search_equal "c:c", "t:artifact"
    assert_search_equal "c:l", "t:land"
  end

  def test_filter_type
    assert_search_results "t:Skeleton", "Drudge Skeletons", "Wall of Bone"
    assert_search_results "t:Basic", "Forest", "Island", "Mountain", "Plains", "Swamp"
    assert_search_include "t:Sorcery", "Act of Treason"
    assert_search_include "t:Jace", "Jace Beleren"
    assert_search_results 't:"Basic Land"', "Forest", "Island", "Mountain", "Plains", "Swamp"
  end

  def test_queries_are_case_insensitive
    assert_search_equal "t:Sorcery", "t:sorcery"
    assert_search_equal "c:b", "c:B"
    assert_search_equal "c:b", "C:B"
    assert_search_equal "c:c", "c!c"
  end

  def test_pow
    assert_search_results "pow=0 c:g", "Birds of Paradise", "Bramble Creeper", "Protean Hydra"
    assert_search_results "pow>=4 c:u", "Air Elemental", "Djinn of Wishes", "Sphinx Ambassador"
    assert_search_results "pow>4 c:u", "Sphinx Ambassador"
    assert_search_results "pow<=4 c:c", "Ornithopter", "Platinum Angel"
    assert_search_results "pow<4 c:c", "Ornithopter"
    assert_search_results "pow=6", "Ball Lightning", "Capricious Efreet", "Craw Wurm"
    assert_search_results "pow<tou c:r", "Dragon Whelp", "Goblin Artillery", "Stone Giant", "Wall of Fire"
    assert_search_results "pow>cmc c:r", "Ball Lightning", "Jackal Familiar"
  end

  def test_tou
    assert_search_results "tou<=cmc c:c", "Darksteel Colossus", "Platinum Angel"
    assert_search_results "tou>=9", "Darksteel Colossus", "Kalonian Behemoth"
    assert_search_results "tou>9", "Darksteel Colossus"
  end

  def test_cmc
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

  def test_oracle
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

  def test_oracle_ignores_remainder_text
    assert_search_results "c:g o:flying", "Birds of Paradise", "Windstorm"
  end

  def test_oracle_cardname
    assert_search_results 'o:"whenever ~ deals combat damage"', "Lightwielder Paladin", "Sphinx Ambassador"
  end

  def test_flavor_text
    assert_search_results "ft:chandra", "Inferno Elemental", "Pyroclasm"
    assert_search_results 'ft:only ft:to', "Acolyte of Xathrid", "Griffin Sentinel", "Wall of Faith", "Zephyr Sprite"
    assert_search_results 'ft:"only to"', "Acolyte of Xathrid"
  end

  def test_artist
    assert_search_results "a:argyle", "Hive Mind"
  end

  def test_banned
    assert_search_results "banned:modern", "Ponder"
    assert_search_results "banned:legacy"
    assert_search_results "banned:vintage"
  end

  def test_restricted
    assert_search_results "restricted:modern"
    assert_search_results "restricted:legacy"
    assert_search_results "restricted:vintage", "Ponder"
  end

  def test_legal
    assert_search_exclude "legal:modern"
    assert_search_include "legal:legacy", "Ponder"
    assert_search_exclude "legal:vintage"
  end

  def test_rarity
    assert_search_results "r:mythic c:c", "Darksteel Colossus", "Platinum Angel"
    assert_search_results "r:rare t:land", "Dragonskull Summit", "Drowned Catacomb", "Gargoyle Castle", "Glacial Fortress", "Rootbound Crag", "Sunpetal Grove"
    assert_search_results "r:uncommon t:equipment", "Gorgon Flail", "Whispersilk Cloak"
    assert_search_results "r:common t:land", "Terramorphic Expanse"
  end

  def test_is_permanent
    assert_search_results "-is:permanent r:mythic", "Time Warp"
  end

  def test_is_opposes_not
    assert_search_equal "not:permanent", "-is:permanent"
    assert_search_equal "not:spell", "-is:spell"
    assert_search_results "not:black-bordered"
    assert_search_equal "not:white-bordered", "not:silver-bordered"
  end

  def test_is_spell
    assert_search_results "e:m10 r:rare ci:c is:spell", "Coat of Arms", "Howling Mine", "Magebane Armor", "Mirror of Fate", "Pithing Needle"
    assert_search_results "e:m10 r:rare ci:c", "Coat of Arms", "Howling Mine", "Magebane Armor", "Mirror of Fate", "Pithing Needle", "Gargoyle Castle"
  end


  def test_loyalty
    assert_search_results "loyalty=5", "Liliana Vess"
    assert_search_results "loyalty>cmc", "Chandra Nalaar"
    assert_search_results "loyalty<=4", "Ajani Goldmane", "Garruk Wildspeaker", "Jace Beleren"
  end

  def test_mana
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
    assert_search_results "mana=11",
      "Darksteel Colossus"
  end
end
