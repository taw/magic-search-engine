require_relative "test_helper"

class CardDatabaseEldrichMoonTest < Minitest::Test
  def setup
    @db = load_database("emn")
  end

  def test_meld_color
    assert_search_results "t:angel c:w", "Bruna, the Fading Light", "Gisela, the Broken Blade", "Subjugator Angel"
    assert_search_results "t:angel c:c", "Brisela, Voice of Nightmares"
  end

  def test_meld_color_identity
    assert_equal Hash[@db.search("is:meld").printings.map{|c| [c.name, c.color_identity]}], {
      # Brisela
      "Brisela, Voice of Nightmares"=>"w",
      "Bruna, the Fading Light"=>"w",
      "Gisela, the Broken Blade"=>"w",
      # Chittering Host
      "Chittering Host"=>"b",
      "Graf Rats"=>"b",
      "Midnight Scavengers"=>"b",
      # Hanweir, the Writhing Township
      "Hanweir Battlements"=>"r",
      "Hanweir Garrison"=>"r",
      "Hanweir, the Writhing Township"=>"r",
    }
  end

  def test_meld_cmc
    assert_search_results "is:meld cmc=0", "Hanweir Battlements"
    assert_search_results "is:meld cmc=2", "Graf Rats"
    assert_search_results "is:meld cmc=3", "Hanweir Garrison", "Hanweir, the Writhing Township"
    assert_search_results "is:meld cmc=4", "Gisela, the Broken Blade"
    assert_search_results "is:meld cmc=5", "Midnight Scavengers"
    assert_search_results "is:meld cmc=7", "Bruna, the Fading Light", "Chittering Host"
    assert_search_results "is:meld cmc=11", "Brisela, Voice of Nightmares"
  end

  def test_is_meld
    assert_search_results "is:meld", "Brisela, Voice of Nightmares", "Bruna, the Fading Light", "Chittering Host", "Gisela, the Broken Blade", "Graf Rats", "Hanweir Battlements", "Hanweir Garrison", "Hanweir, the Writhing Township", "Midnight Scavengers"
    assert_search_equal "layout:meld", "is:meld"
  end
end
