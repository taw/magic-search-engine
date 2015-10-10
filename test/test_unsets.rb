require_relative "test_helper"

class CardDatabaseUnsetsTest < Minitest::Test
  def setup
    @db = CardDatabase.new(Pathname(__dir__) + "index/unsets.json")
  end

  def test_half_pow
    assert_search_exclude "pow=1", "Little Girl"
    assert_search_include "pow>0", "Little Girl"
    assert_search_include "pow=0.5", "Little Girl"
    assert_search_include "pow=½", "Little Girl"
    assert_search_include "pow<1", "Little Girl"
    assert_search_exclude "pow=1", "Little Girl"
    assert_search_exclude "pow>1", "Little Girl"

    assert_search_include "pow=tou"
    assert_search_include "pow=cmc"
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

  def test_half_cmc

  end

  def is_funny
    assert_search_include "is:funny", "Little Girl"
    assert_search_include "is:new", "Little Girl"
    assert_search_include "is:silver-bordered", "Little Girl"
    assert_search_include "not:black-bordered", "Little Girl"
    assert_search_include "not:white-bordered", "Little Girl"
  end
end
