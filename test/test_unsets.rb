require_relative "test_helper"

class CardDatabaseUnsetsTest < Minitest::Test
  def setup
    @db = load_database("ug", "uh", "uqc")
  end

  def test_half_pow
    assert_search_exclude "pow=1", "Little Girl"
    assert_search_include "pow>0", "Little Girl"
    assert_search_include "pow=0.5", "Little Girl"
    assert_search_include "pow=½", "Little Girl"
    assert_search_include "pow<1", "Little Girl"
    assert_search_exclude "pow=1", "Little Girl"
    assert_search_exclude "pow>1", "Little Girl"
    assert_search_include "pow=tou", "Little Girl"
    assert_search_include "pow=cmc", "Little Girl"
  end

  def test_half_tou
    assert_search_exclude "tou=1", "Little Girl"
    assert_search_include "tou>0", "Little Girl"
    assert_search_include "tou=0.5", "Little Girl"
    assert_search_include "tou=½", "Little Girl"
    assert_search_include "tou<1", "Little Girl"
    assert_search_exclude "tou=1", "Little Girl"
    assert_search_exclude "tou>1", "Little Girl"
  end

  def test_half_cmc
    assert_search_exclude "cmc=1", "Little Girl"
    assert_search_include "cmc>0", "Little Girl"
    assert_search_include "cmc=0.5", "Little Girl"
    assert_search_include "cmc=½", "Little Girl"
    assert_search_include "cmc<1", "Little Girl"
    assert_search_exclude "cmc=1", "Little Girl"
    assert_search_exclude "cmc>1", "Little Girl"
  end

  def test_is_funny
    assert_search_include "is:funny", "Little Girl"
    assert_search_include "is:new", "Little Girl"
    assert_search_include "is:silver-bordered", "Little Girl"
    assert_search_include "not:black-bordered", "Little Girl"
    assert_search_include "not:white-bordered", "Little Girl"
    assert_search_results "not:funny"
    assert_search_include "not:new", "1996 World Champion", "Fraternal Exaltation", "Proposal", "Shichifukujin Dragon", "Splendid Genesis"

    assert_search_equal "not:new", "(-e:uh) -(Robot Chicken)"
    assert_search_results "not:silver-bordered", "Forest", "Mountain", "Swamp", "Plains", "Island", "1996 World Champion", "Fraternal Exaltation", "Proposal", "Robot Chicken", "Shichifukujin Dragon", "Splendid Genesis"
    assert_search_results "is:black-bordered", "Forest", "Mountain", "Swamp", "Plains", "Island", "1996 World Champion", "Fraternal Exaltation", "Proposal", "Robot Chicken", "Shichifukujin Dragon", "Splendid Genesis"
    assert_search_results "is:white-bordered"
  end

  # I'm not sure I want this syntax
  # def test_edition_shortcut_syntax
  #   assert_search_equal "e:uh,ug", "e:uh or e:ug"
  #   assert_search_equal "e:uh+ug", "t:basic"
  #   assert_count_results "e:uh,ug", 227
  #   assert_count_results "e:uh,ug -e:ug+ug", 222
  # end

  def test_other
    assert_search_results "other:c:g", "What", "Who", "When", "Where"
    # Any other has cmc != 4
    assert_search_results "other:-cmc=4", "Who", "What", "When", "Where", "Why"
    # Doesn't have other side with cmc=4
    # This includes Where (cmc=4) and all single-sided cards
    assert_search_include "-other:cmc=4", "Where", "Chicken Egg"
    assert_search_exclude "-other:cmc=4", "What", "Who", "Why", "When"
  end

  def test_mana_xyz
    assert_search_results "mana>=xyz", "The Ultimate Nightmare of Wizards of the Coast® Customer Service"
    assert_search_results "mana>={x}{z}", "The Ultimate Nightmare of Wizards of the Coast® Customer Service"
  end

  def test_mana_hw
    assert_search_results "mana={hw}", "Little Girl"
    assert_search_equal "mana={hw}{hw}", "mana=w"
    assert_search_equal "mana>{hw}{hw}", "mana>w"
    assert_search_differ "mana>={hw}", "mana>=0"
    assert_search_differ "mana>={hw}", "mana>=w"
    assert_search_equal "mana>{hw}", "mana>=w"
  end

  def test_split_slash_slash_bang
    assert_search_results "!When / Where // What && Why", "Who", "What", "When", "Where", "Why"
    assert_search_results "!When // Where // Whatever"
  end

  def test_split_slash_slash
    assert_search_results "//", "Who", "What", "When", "Where", "Why", "B.F.M. (Big Furry Monster)"
    assert_search_results "When // Where // What", "Who", "What", "When", "Where", "Why"
    assert_search_results "When // Where // Whatever"
    assert_search_results "c:u // c:w // c:r", "Who", "What", "When", "Where", "Why"
    assert_search_results "c:u // c:u"

    # This is limitation of the syntax, I might change my mind about it,
    # but it only affects this one uncard
    assert_search_results "c:u // c:r // c:u", "Who", "What", "When", "Where", "Why"
  end

  def test_dos_protection_other
    assert_search_results("other:"*20 + "cmc=1", "Who", "What", "When", "Where", "Why")
    assert_search_results("other:"*20 + "cmc=6")
  end

  def test_dos_protection_part
    assert_search_results("part:"*20 + "cmc=1", "Who", "What", "When", "Where", "Why")
    assert_search_results("part:"*20 + "cmc=6")
  end
end
