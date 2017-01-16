describe "Planechase" do
  include_context "db", "pch", "pc2", "pca"

  it "plane" do
    assert_search_results "t:plane t:Dominaria", "Krosa", "Llanowar", "Academy at Tolaria West", "Isle of Vesuva", "Otaria", "Shiv", "Talon Gates"
    assert_search_results "t:Dominaria", "Krosa", "Llanowar", "Academy at Tolaria West", "Isle of Vesuva", "Otaria", "Shiv", "Talon Gates"
    assert_search_equal "t:plane", "layout:plane"
  end

  it "chaos_symbol" do
    # Maybe should be something else than CHAOS ?
    assert_search_results %Q[t:plane o:"whenever you roll {CHAOS}, untap all creatures you control"], "Llanowar"
  end

  it "phenomenon" do
    assert_search_results %Q[t:phenomenon o:"each player draws four cards"], "Mutual Epiphany"
  end

  it "bang_search_doesnt_require_explicit_flags" do
    assert_search_results "!Talon Gates", "Talon Gates"
    assert_search_results "!Mutual Epiphany", "Mutual Epiphany"
  end

  it "plane_cards_not_included_unless_requested" do
    assert_search_results 'o:"untap all creatures you control"'
  end

  it "phenomenon_cards_not_included_unless_requested" do
    assert_search_results %Q[o:"each player draws four cards"]
  end
end
