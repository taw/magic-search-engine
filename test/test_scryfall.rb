# Examples from https://scryfall.com/docs/syntax
# and how they work on mtg.wtf

require_relative "test_helper"

class ScryfallTest < Minitest::Test
  def setup
    @db = load_database
  end

  def test_crg_and_or
    # we follow MCI style AND
    assert_search_equal "c:rg", "c:r OR c:g"
    # scryfall follows AND
    assert_search_differ "c:rg", "c:r AND c:g"
    # It's arguable which behaviour is better
  end

  # FIXME: scryfall supports "c:red" too
  def test_color_alias
    # color: is alias for c:
    assert_search_equal "color:uw -c:r", "(c:u OR c:w) -c:r"
    # it's still OR, not AND
    assert_search_differ "color:uw -c:r", "(c:u AND c:w) -c:r"
  end

  def test_colorless
    # results differ due to uncards, but functionality is overall the same
    assert_search_include "c:c t:creature",
      "Abundant Maw",
      "Accomplished Automaton",
      "Barrage Tyrant",
      "Bastion Mastodon"
  end

  def test_multicolor
    # results are the same (except for scryfall including spoiler cards)
    assert_search_include "c:m t:instant",
      "Abrupt Decay",
      "Aethertow",
      "Bound",
      "Determined"
    # This is arguable case as both sides are monocolored,
    # but full cards is sort of multicolored (fuse or no fuse)
    assert_search_exclude "c:m t:instant",
      "Turn", "Burn",
      "Fire", "Ice"
  end

  def test_creature_type
    # scryfall includes changelings as every creature type
    assert_search_include "t:merfolk t:legendary",
      "Jori En, Ruin Diver"
    assert_search_exclude "t:merfolk t:legendary",
      "Mistform Ultimus"
  end

  def test_tribal_type
    # scryfall includes changelings as every creature type
    assert_search_include "t:goblin -t:creature",
      "Tarfire"
    assert_search_exclude "t:goblin -t:creature",
      "Ego Erasure"
  end

  def test_scryfall_bug_cmc
    # meld cmc is sum of part cmcs, scryfall bug
    assert_search_exclude "c:c t:creature cmc=0", "Chittering Host"
  end

  def test_scryfall_bug_uncards
    assert_search_include "clay", "Clay Pigeon"
  end
end
