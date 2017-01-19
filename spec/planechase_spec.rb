describe "Planechase" do
  include_context "db", "pch", "pc2", "pca"

  it "plane" do
    assert_search_results "t:plane t:Dominaria", "Krosa", "Llanowar", "Academy at Tolaria West", "Isle of Vesuva", "Otaria", "Shiv", "Talon Gates"
    assert_search_results "t:Dominaria", "Krosa", "Llanowar", "Academy at Tolaria West", "Isle of Vesuva", "Otaria", "Shiv", "Talon Gates"
    assert_search_equal "t:plane", "layout:plane"
  end

  it "chaos symbol" do
    # Maybe should be something else than CHAOS ?
    assert_search_results %Q[t:plane o:"whenever you roll {CHAOS}, untap all creatures you control"], "Llanowar"
  end

  it "phenomenon" do
    assert_search_results %Q[t:phenomenon o:"each player draws four cards"], "Mutual Epiphany"
  end

  it "bang search doesn't require explicit flags" do
    assert_search_results "!Talon Gates", "Talon Gates"
    assert_search_results "!Mutual Epiphany", "Mutual Epiphany"
  end

  it "plane cards included by default" do
    assert_search_results 'o:"untap all creatures you control"',
      "Llanowar"
  end

  it "phenomenon cards included by default" do
    assert_search_results %Q[o:"each player draws four cards"],
      "Mutual Epiphany"
  end
end
