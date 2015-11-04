require_relative "test_helper"

class CardDatabaseNewPhyrexiaTest < Minitest::Test
  def setup
    @db = load_database("nph")
    @birthing_pod = @db.search("Birthing Pod").printings[0]
  end

  def test_phyrexian_mana
    assert_search_results "mana>=3{GP}", "Birthing Pod", "Thundering Tanadon"
    assert_search_results "mana>=3{p/g}", "Birthing Pod", "Thundering Tanadon"
  end

  def test_watermark
    assert_search_results "w:mirran c:g", "Greenhilt Trainee", "Melira, Sylvok Outcast", "Viridian Harvest"
  end

  def test_gatherer_link
    assert_equal(
      "http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=218006",
      @birthing_pod.gatherer_link
    )
  end

  def test_magiccards_info_link
    assert_equal(
      "http://magiccards.info/nph/en/104.html",
      @birthing_pod.magiccards_info_link
    )
  end

  def test_legalities
    assert_equal(
      {
        "modern" => "banned",
        "scars of mirrodin block" => "legal",
        "legacy" => "legal",
        "vintage" => "legal",
        "commander" => "legal",
      },
      @birthing_pod.all_legalities
    )
  end

  def test_legalities_time
    rtr_release_date = Date.parse("2012-10-05")
    assert_equal(
      {
        "modern" => "legal",
        "scars of mirrodin block" => "legal",
        "legacy" => "legal",
        "vintage" => "legal",
        "commander" => "legal",
      },
      @birthing_pod.all_legalities(rtr_release_date)
    )
  end
end
