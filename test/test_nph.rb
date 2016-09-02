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
    assert_search_equal "w:mirran OR w:phyrexian", "w:*"
    assert_search_equal "-w:mirran -w:phyrexian", "-w:*"
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
        "Modern" => "banned",
        "Scars of Mirrodin Block" => "legal",
        "Legacy" => "legal",
        "Vintage" => "legal",
        "Commander" => "legal",
      },
      @birthing_pod.legality_information.to_h
    )
  end

  def test_legalities_time
    rtr_release_date = Date.parse("2012-10-05")
    assert_equal(
      {
        "Modern" => "legal",
        "Scars of Mirrodin Block" => "legal",
        "Legacy" => "legal",
        "Vintage" => "legal",
        "Commander" => "legal",
      },
      @birthing_pod.legality_information(rtr_release_date).to_h
    )
  end
end
