require_relative "test_helper"

class CardDatabaseFullTest < Minitest::Test
  def setup
    @db = load_database
  end

  def test_stats
    assert_equal 15396, @db.cards.size
    assert_equal 29146, @db.printings.size
  end

  def test_formats
    assert_search_equal "f:standard", "legal:standard"
    assert_search_results "f:extended" # Does not exist according to mtgjson
    assert_search_equal "f:standard", "e:m15 or e:ori or e:ktk or e:frf or e:dtk or e:bfz" # M15 is a lie
    assert_search_equal 'f:"ravnica block"', "e:rav or e:gp or e:di"
  end

  def test_block_codes
    assert_search_equal "b:rtr", 'b:"Return to Ravnica"'
    assert_search_equal "b:in", 'b:Invasion'
    assert_search_equal "b:som", 'b:"Scars of Mirrodin"'
    assert_search_equal "b:som", 'b:scars'
    assert_search_equal "b:mi", 'b:Mirrodin'
  end

  def test_block_special_characters
    assert_search_equal %Q[b:us], "b:urza"
    assert_search_equal %Q[b:"Urza's"], "b:urza"
  end

  def test_block_contents
    assert_search_equal "e:rtr OR e:gtc OR e:dgm", "b:rtr"
    assert_search_equal "e:in or e:ps or e:ap", 'b:Invasion'
    assert_search_equal "e:isd or e:dka or e:avr", "b:Innistrad"
    assert_search_equal "e:lw or e:mt or e:shm or e:eve", "b:lorwyn"
    assert_search_equal "e:som or e:mbs or e:nph", "b:som"
    assert_search_equal "e:mi or e:ds or e:5dn", "b:mi"
    assert_search_equal "e:som", 'e:scars'
    assert_search_equal 'f:"lorwyn-shadowmoor block"', "b:lorwyn"
  end

  def test_edition_special_characters
    assert_search_equal "e:us", %Q[e:"Urza's Saga"]
    assert_search_equal "e:us", %Q[e:"Urza’s Saga"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza's"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza’s"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza"]
  end

  def test_part
    assert_search_results "part:cmc=1 part:cmc=2", "Death", "Life", "Tear", "Wear", "What", "When", "Where", "Who", "Why"
    assert_search_results "part:cmc=0 part:cmc=3 part:c:b", "Chosen of Markov", "Liliana, Defiant Necromancer", "Liliana, Heretical Healer", "Markov's Servant", "Screeching Bat", "Stalking Vampire"
  end

  def test_color_identity
     assert_search_results "ci:wu t:basic", "Island", "Plains", "Snow-Covered Island", "Snow-Covered Plains"
   end
end
