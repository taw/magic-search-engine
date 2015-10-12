require_relative "test_helper"

class CardDatabaseNewPhyrexiaTest < Minitest::Test
  def setup
    @db = load_database("nph")
  end

  def test_phyrexian_mana
    assert_search_results "mana>=3{GP}", "Birthing Pod", "Thundering Tanadon"
  end

  def test_watermark
    assert_search_results "watermark:mirran c:g", "Greenhilt Trainee", "Melira, Sylvok Outcast", "Viridian Harvest"
  end
end
