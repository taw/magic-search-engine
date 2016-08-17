require_relative "test_helper"

class PrintedTest < Minitest::Test
  def setup
    @db = load_database
  end

  def test_first_printed
    # included in "all" and "full" sets, not in "expert"
    assert_search_results "firstprint=fvr", "Sword of Body and Mind"
    assert_search_results "firstprint*=fvr", "Sword of Body and Mind"
    assert_search_results "firstprint!=fvr"

    # all new ktk cards -> minus dd:svc -> minus pre-re promos
    assert_count_results "firstprint!=ktk", 231
    assert_count_results "firstprint=ktk", 223
    assert_count_results "firstprint*=ktk", 187

    assert_search_results "firstprint=be",
      "Circle of Protection: Black",
      "Volcanic Island"
  end

  def test_last_printed
    # cards not reprinted into std since rv -> minus commander cards -> minus online MED cards
    assert_count_results "lastprint!=rv", 44
    assert_count_results "lastprint=rv", 39
    assert_count_results "lastprint*=rv", 13

    # everything that hasn't been printed since fvr
    assert_search_results "lastprint=fvr",
      "Black Vise",
      "Ivory Tower",
      "Jester's Cap",
      "Karn, Silver Golem",
      "Masticore",
      "Memory Jar",
      "Mox Diamond",
      "Sundering Titan",
      "Zuran Orb"
    # excludes cards reprinted in vintage masters
    assert_search_results "lastprint*=fvr",
      "Black Vise",
      "Jester's Cap",
      "Sundering Titan",
      "Zuran Orb"
    # no results in ! query since fvr isn't a core or expansion
    assert_search_results "lastprint!=fvr"

    assert_count_results "lastprint!=un", 27
    assert_count_results "lastprint=un", 25
    assert_count_results "lastprint*=un", 5
  end

  def test_unique_scenarios
    # all reserved list cards that have been reprinted in paper nonetheless
    assert_search_results "(lastprint>ud is:reserved) OR (lastprint*>ud st:promo is:reserved)",
      "Deranged Hermit",
      "Intuition",
      "Karn, Silver Golem",
      "Lightning Dragon",
      "Masticore",
      "Memory Jar",
      "Morphling",
      "Mox Diamond",
      "Phyrexian Dreadnought",
      "Phyrexian Negator",
      "Powder Keg",
      "Survival of the Fittest",
      "Thawing Glaciers",
      "Wheel of Fortune",
      "Yawgmoth's Will"
  end
end
