require_relative "test_helper"

class CardDatabaseDissentionTest < Minitest::Test
  def setup
    @db = CardDatabase.new(Pathname(__dir__) + "index/dis.json")
  end

  def test_transguild_courier
    assert_search_include "c:wubrg", "Transguild Courier"
    assert_search_include "c!wubrg", "Transguild Courier"
    assert_search_include "ci:wubrg", "Transguild Courier"
    assert_search_include "is:vanilla", "Transguild Courier"
  end
end
