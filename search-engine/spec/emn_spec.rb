describe "Eldrich Moon" do
  include_context "db", "emn"

  it "meld color" do
    assert_search_results "t:angel c:w",
      "Bruna, the Fading Light",
      "Gisela, the Broken Blade", "Subjugator Angel"
    assert_search_results "t:angel c:c",
      "Brisela, Voice of Nightmares"
  end

  it "meld color identity" do
    Hash[db.search("is:meld").printings.map{|c| [c.name, c.color_identity]}].should == {
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

  it "is:meld" do
    assert_search_results "is:meld",
      "Brisela, Voice of Nightmares",
      "Bruna, the Fading Light",
      "Chittering Host",
      "Gisela, the Broken Blade",
      "Graf Rats",
      "Hanweir Battlements",
      "Hanweir Garrison",
      "Hanweir, the Writhing Township",
      "Midnight Scavengers"
    assert_search_equal "layout:meld", "is:meld"
  end

  it "is:meldpart" do
    assert_search_results "is:meldpart",
      "Bruna, the Fading Light",
      "Gisela, the Broken Blade",
      "Graf Rats",
      "Hanweir Battlements",
      "Hanweir Garrison",
      "Midnight Scavengers"
  end

  it "is:meldresult" do
    assert_search_results "is:meldresult",
      "Brisela, Voice of Nightmares",
      "Chittering Host",
      "Hanweir, the Writhing Township"
  end

  it "meld parts and results together are all meld cards" do
    assert_search_equal "is:meldpart or is:meldresult", "is:meld"
    assert_search_results "is:meldpart is:meldresult"
  end

  it "is:primary" do
    assert_search_results "is:primary layout:meld",
      "Bruna, the Fading Light",
      "Gisela, the Broken Blade",
      "Graf Rats",
      "Hanweir Battlements",
      "Hanweir Garrison",
      "Midnight Scavengers"
    assert_search_results "not:primary layout:meld",
      "Brisela, Voice of Nightmares",
      "Chittering Host",
      "Hanweir, the Writhing Township"
  end

  it "is:front / is:primary" do
    assert_search_equal "is:front", "is:primary"
  end

  it "is:secondary / is:back" do
    assert_search_equal "is:back", "is:secondary"
  end
end
