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
    assert_search_equal "f:standard", "e:ori or e:ktk or e:frf or e:dtk or e:bfz"
    assert_search_equal 'f:"ravnica block"', "e:rav or e:gp or e:di"
  end

  def test_part
    assert_search_results "part:cmc=1 part:cmc=2", "Death", "Life", "Tear", "Wear", "What", "When", "Where", "Who", "Why"
    assert_search_results "part:cmc=0 part:cmc=3 part:c:b", "Chosen of Markov", "Liliana, Defiant Necromancer", "Liliana, Heretical Healer", "Markov's Servant", "Screeching Bat", "Stalking Vampire"
  end
end
