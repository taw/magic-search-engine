require_relative "test_helper"

class CardDatabaseAlphaTest < Minitest::Test
  def setup
    @db = CardDatabase.new(Pathname(__dir__) + "index/al.json")
  end

  def test_legality
    assert_search_equal "f:edh", "f:commander"
    assert_search_equal "legal:edh", "legal:commander"
    assert_search_equal "f:legacy", "-banned:legacy"
    assert_search_equal "f:vintage", "-banned:vintage"
  end
end
