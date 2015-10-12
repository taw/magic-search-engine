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
    assert_search_include "not:new", "1996 World Champion", "Fraternal Exaltation", "Proposal", "Robot Chicken", "Shichifukujin Dragon", "Splendid Genesis"
    assert_search_equal "not:new", "-e:uh"
    assert_search_results "not:silver-bordered", "Forest", "Mountain", "Swamp", "Plains", "Island", "1996 World Champion", "Fraternal Exaltation", "Proposal", "Robot Chicken", "Shichifukujin Dragon", "Splendid Genesis"
    assert_search_results "is:black-bordered", "Forest", "Mountain", "Swamp", "Plains", "Island", "1996 World Champion", "Fraternal Exaltation", "Proposal", "Robot Chicken", "Shichifukujin Dragon", "Splendid Genesis"
    assert_search_results "is:white-bordered"
  end

  def test_edition_shortcut_syntax
    assert_search_equal "e:uh,ug", "e:uh or e:ug"
    assert_search_equal "e:uh+ug", "t:basic"
    assert_count_results "e:uh,ug", 227
    assert_count_results "e:uh,ug -e:ug+ug", 222
  end
end
