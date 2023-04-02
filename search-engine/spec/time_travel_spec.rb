describe "Time Travel Test" do
  include_context "db"

  it "time travel basic" do
    assert_search_equal "time:lw t:planeswalker", "e:lw t:planeswalker"
    assert_search_results "time:wwk t:jace", "Jace Beleren", "Jace, the Mind Sculptor"
  end

  it "time travel printed" do
    assert_search_equal "time:lw t:planeswalker", "e:lw t:planeswalker"
    assert_search_results "t:jace lastprint=wwk"
    assert_search_results "t:jace print=vma", "Jace, the Mind Sculptor"
    assert_search_results "time:nph t:jace lastprint=wwk", "Jace, the Mind Sculptor"
    assert_search_results "time:nph t:jace print=vma"
  end

  it "time travel Gatherer/MCI names" do
    assert_search_equal "time:MRD f:standard", "time:mi f:standard"
  end

  it "time travel standard legal reprints activate in block" do
    assert_search_results 'f:"return to ravnica block" naturalize', "Naturalize"
    assert_search_results 'time:rtr f:"return to ravnica block" naturalize'
    assert_search_results 'time:gtc f:"return to ravnica block" naturalize', "Naturalize"
    assert_search_results 'time:dgm f:"return to ravnica block" naturalize', "Naturalize"
  end

  it "time travel standard legal reprints activate in modern" do
    assert_search_results "f:legacy rancor", "Rancor"
    assert_search_results "f:modern rancor", "Rancor"
    assert_search_results "time:m11 f:legacy rancor", "Rancor"
    assert_search_results "time:m11 f:modern rancor"
  end

  it "time travel eternal formats accept all black border sets (even UNF)" do
    assert_search_equal "f:legacy t:jace", "t:jace"
    assert_search_equal "f:legacy time:nph t:jace", "time:nph t:jace"
    assert_search_equal "f:vintage t:jace", "t:jace"
    assert_search_equal "f:vintage time:nph t:jace", "time:nph t:jace"
    assert_search_equal "f:commander t:jace", "t:jace"
    assert_search_equal "f:commander time:nph t:jace", "time:nph t:jace"
  end

  it "time travel error handling" do
    # Empty search returns all cards
    assert_count_printings "", db.printings.size
    assert_count_printings "sort:new", db.printings.size
    assert_count_printings "is:spell or t:land", db.printings.size
    assert_count_printings "time:3000", db.printings.size
    assert_count_printings %[time:"battle for homelands"], db.printings.size
    assert_count_printings "time:1000", 0
    assert_search_equal %[time:"battle for homelands" f:standard], "f:standard"
  end

  it "time travel scoped" do
    assert_search_equal "(time:KLD f:standard) not (time:AER f:standard)",
      "(Emrakul, the Promised End -e:sir) or (time:OGW Reflector Mage) or (Smuggler's Copter -e:nec -e:sld)"
    # Reprints complicate this
    assert_search_equal_cards "(time:OGW f:Standard) not (time:SOI f:Standard)",
      "(e:KTK or e:FRF) -t:basic -(Act of Treason) -(Dutiful Return) -(Naturalize)
      -(Summit Prowler) -(Smite the Monstrous)
      -(Throttle) -(Tormenting Voice) -(Weave Fate) -(Incremental Growth)"
  end
end
