require_relative "test_helper"

class CardDatabaseAlphaTest < Minitest::Test
  def setup
    @db = load_database
  end

  def test_legality
    assert_search_equal "e:al f:edh", "e:al f:commander"
    assert_search_equal "e:al legal:edh", "e:al legal:commander"
    assert_search_equal "e:al f:legacy", "e:al -banned:legacy"
    assert_search_equal "e:al f:vintage", "e:al -banned:vintage"
    assert_search_equal "e:al f:modern", "e:al legal:modern"
  end

  def test_reserved
    assert_search_include "is:reserved", "Black Lotus"
    assert_search_include "not:reserved", "Shivan Dragon"
  end
end
