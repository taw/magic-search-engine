require_relative "test_helper"

class CardDatabasePlanechaseTest < Minitest::Test
  def setup
    @db = load_database("pch", "pc2")
  end

  def test_plane
    assert_search_results "t:plane t:Dominaria", "Krosa", "Llanowar", "Academy at Tolaria West", "Isle of Vesuva", "Otaria", "Shiv", "Talon Gates"
    assert_search_results "t:Dominaria", "Krosa", "Llanowar", "Academy at Tolaria West", "Isle of Vesuva", "Otaria", "Shiv", "Talon Gates"
  end

  def test_chaos_symbol
    # Maybe should be something else than CHAOS ?
    assert_search_results %Q[t:plane o:"whenever you roll CHAOS, untap all creatures you control"], "Llanowar"
  end

  def test_phenomenon
    assert_search_results %Q[t:phenomenon o:"each player draws four cards"], "Mutual Epiphany"
  end

  def test_bang_search_doesnt_require_explicit_flags
    assert_search_results "!Talon Gates", "Talon Gates"
    assert_search_results "!Mutual Epiphany", "Mutual Epiphany"
  end

  def test_plane_cards_not_included_unless_requested
    assert_search_results 'o:"untap all creatures you control"'
  end

  def test_phenomenon_cards_not_included_unless_requested
    assert_search_results %Q[o:"each player draws four cards"]
  end
end

