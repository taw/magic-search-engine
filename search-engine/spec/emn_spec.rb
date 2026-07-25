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

  it "meld cmc" do
    assert_search_results "is:meld cmc=0", "Hanweir Battlements"
    assert_search_results "is:meld cmc=2", "Graf Rats"
    assert_search_results "is:meld cmc=3", "Hanweir Garrison", "Hanweir, the Writhing Township"
    assert_search_results "is:meld cmc=4", "Gisela, the Broken Blade"
    assert_search_results "is:meld cmc=5", "Midnight Scavengers"
    assert_search_results "is:meld cmc=7", "Bruna, the Fading Light", "Chittering Host"
    assert_search_results "is:meld cmc=11", "Brisela, Voice of Nightmares"
  end

  it "dfc cmc" do
    # back face has same mana value as front face, it doesn't get 0
    assert_search_results "layout:transform cmc=0"
    assert_search_results "layout:transform cmc=1",
      "Kessig Prowler", "Sinuous Predator"
    assert_search_results "layout:transform cmc=2",
      "Curious Homunculus", "It That Rides as One", "Lone Rider",
      "Ulvenwald Abomination", "Ulvenwald Captive", "Voracious Reader"
    assert_search_results "layout:transform cmc=3",
      "Aurora of Emrakul", "Conduit of Emrakul", "Conduit of Storms",
      "Cryptolith Fragment", "Extricator of Flesh", "Extricator of Sin",
      "Grisly Anglerfish", "Grizzled Angler", "Howling Chorus", "Shrill Howler"
    assert_search_results "layout:transform cmc=4",
      "Erupting Dreadwolf", "Fibrous Entangler",
      "Smoldering Werewolf", "Tangleclaw Werewolf"
    assert_search_results "layout:transform cmc=5",
      "Abolisher of Bloodlines", "Docent of Perfection", "Dronepack Kindred",
      "Final Iteration", "Ulrich of the Krallenhorde", "Ulrich, Uncontested Alpha",
      "Vildin-Pack Outcast", "Voldaren Pariah"
  end

  it "dfc cmc is same on both sides" do
    (1..5).each do |cmc|
      assert_search_equal "layout:transform cmc=#{cmc}", "layout:transform other:cmc=#{cmc}"
    end
  end

  it "mv is an alias of cmc" do
    assert_search_equal "layout:transform mv=5", "layout:transform cmc=5"
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
