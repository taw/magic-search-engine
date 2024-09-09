describe "New Phyrexia" do
  include_context "db", "nph"

  let(:birthing_pod) { db.search("Birthing Pod").printings[0] }

  it "phyrexian mana" do
    assert_search_results "mana>=3{GP}", "Birthing Pod", "Thundering Tanadon"
    assert_search_results "mana>=3{p/g}", "Birthing Pod", "Thundering Tanadon"
  end

  it "watermark:" do
    assert_search_results "w:mirran c:g", "Greenhilt Trainee", "Melira, Sylvok Outcast", "Viridian Harvest"
    assert_search_equal "w:mirran OR w:phyrexian", "w:*"
    assert_search_equal "-w:mirran -w:phyrexian", "-w:*"
    assert_search_equal "has:watermark", "w:*"
  end

  it "gatherer link" do
    birthing_pod.gatherer_link.should eq("http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=218006")
  end

  it "legalities" do
    birthing_pod.legality_information.to_h.should eq({
      "Modern" => "banned",
      "Scars of Mirrodin Block" => "legal",
      "Legacy" => "legal",
      "Vintage" => "legal",
      "Commander" => "legal",
      "Duel Commander" => "legal",
      # "MTGO Commander" => "legal",
    })
  end

  it "legalities_time" do
    rtr_release_date = Date.parse("2012-10-05")
    birthing_pod.legality_information(rtr_release_date).to_h.should eq({
      "Modern" => "legal",
      "Scars of Mirrodin Block" => "legal",
      "Legacy" => "legal",
      "Vintage" => "legal",
      "Commander" => "legal",
      "Duel Commander" => "legal",
      # "MTGO Commander" => "legal",
    })
  end

  let(:alloy_myr)    { db.cards["alloy myr"].printings[0] }
  let(:pristine_talisman) { db.cards["pristine talisman"].printings[0] }

  it "artists" do
    alloy_myr.artist_name.should eq("Matt Cavotta")
    alloy_myr.artist.name.should eq("Matt Cavotta")
    mattr_cavotta = alloy_myr.artist
    mattr_cavotta.printings.select{|c| c.set_code == "nph"}.should == [alloy_myr, pristine_talisman]
  end

  it "Phyrexian mana Oracle search" do
    assert_search_results %[o:"{p/u}"], "Spellskite", "Trespassing Souleater"
    assert_search_results %[o:"{u/p}"], "Spellskite", "Trespassing Souleater"
    assert_search_results %[o:"{P/U}"], "Spellskite", "Trespassing Souleater"
    assert_search_results %[o:"{U/P}"], "Spellskite", "Trespassing Souleater"
    assert_search_results %[o:"{pu}"], "Spellskite", "Trespassing Souleater"
    assert_search_results %[o:"{up}"], "Spellskite", "Trespassing Souleater"
  end
end
