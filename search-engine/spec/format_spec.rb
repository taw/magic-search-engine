describe "Formats" do
  include_context "db"

  ## General queries

  it "formats" do
    assert_search_equal "f:standard", "legal:standard"
    assert_search_results "f:extended" # Does not exist according to mtgjson
    assert_search_equal "f:standard",
      %Q[(e:kld or e:aer or e:akh or e:w17 or e:hou or e:xln) -"Smuggler's Copter" -"Felidar Guardian" -"Aetherworks Marvel"]
    assert_search_equal 'f:"ravnica block"', "e:rav or e:gp or e:di"
    assert_search_equal 'f:"ravnica block"', 'legal:"ravnica block"'
    assert_search_equal 'f:"ravnica block"', 'b:ravnica'
    assert_search_differ 'f:"mirrodin block" t:land', 'b:"mirrodin" t:land'
  end

  it "ban_events" do
    FormatInnistradBlock.new.ban_events.should eq([
       [Date.parse("2012-04-01"), nil, [
         {name: "Intangible Virtue", old: "legal", new: "banned"},
         {name: "Lingering Souls", old: "legal", new: "banned"},
       ]],
    ])
    FormatModern.new.ban_events.should eq([
      [Date.parse("2017-01-20"), nil, [
        {:name=>"Golgari Grave-Troll", :old=>"legal", :new=>"banned"},
        {:name=>"Gitaxian Probe", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2016-04-08"), nil, [
        {:name=>"Ancestral Vision", :old=>"banned", :new=>"legal"},
        {:name=>"Sword of the Meek", :old=>"banned", :new=>"legal"},
        {:name=>"Eye of Ugin", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2016-01-22"), nil, [
        {:name=>"Splinter Twin", :old=>"legal", :new=>"banned"},
        {:name=>"Summer Bloom", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2015-01-23"), nil, [
        {:name=>"Golgari Grave-Troll", :old=>"banned", :new=>"legal"},
        {:name=>"Birthing Pod", :old=>"legal", :new=>"banned"},
        {:name=>"Dig Through Time", :old=>"legal", :new=>"banned"},
        {:name=>"Treasure Cruise", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2014-02-07"), nil, [
        {:name=>"Bitterblossom", :old=>"banned", :new=>"legal"},
        {:name=>"Wild Nacatl", :old=>"banned", :new=>"legal"},
        {:name=>"Deathrite Shaman", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2013-05-03"), nil, [
        {:name=>"Second Sunrise", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2013-02-01"), nil, [
        {:name=>"Bloodbraid Elf", :old=>"legal", :new=>"banned"},
        {:name=>"Seething Song", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2012-10-01"), nil, [
        {:name=>"Valakut, the Molten Pinnacle", :old=>"banned", :new=>"legal"},
      ]],
      [Date.parse("2012-01-01"), nil, [
        {:name=>"Punishing Fire", :old=>"legal", :new=>"banned"},
        {:name=>"Wild Nacatl", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2011-10-01"), nil, [
        {:name=>"Blazing Shoal", :old=>"legal", :new=>"banned"},
        {:name=>"Cloudpost", :old=>"legal", :new=>"banned"},
        {:name=>"Green Sun's Zenith", :old=>"legal", :new=>"banned"},
        {:name=>"Ponder", :old=>"legal", :new=>"banned"},
        {:name=>"Preordain", :old=>"legal", :new=>"banned"},
        {:name=>"Rite of Flame", :old=>"legal", :new=>"banned"},
      ]],
      [nil, nil, [
        {:name=>"Ancestral Vision", :old=>"legal", :new=>"banned"},
        {:name=>"Ancient Den", :old=>"legal", :new=>"banned"},
        {:name=>"Bitterblossom", :old=>"legal", :new=>"banned"},
        {:name=>"Chrome Mox", :old=>"legal", :new=>"banned"},
        {:name=>"Dark Depths", :old=>"legal", :new=>"banned"},
        {:name=>"Dread Return", :old=>"legal", :new=>"banned"},
        {:name=>"Glimpse of Nature", :old=>"legal", :new=>"banned"},
        {:name=>"Golgari Grave-Troll", :old=>"legal", :new=>"banned"},
        {:name=>"Great Furnace", :old=>"legal", :new=>"banned"},
        {:name=>"Hypergenesis", :old=>"legal", :new=>"banned"},
        {:name=>"Jace, the Mind Sculptor", :old=>"legal", :new=>"banned"},
        {:name=>"Mental Misstep", :old=>"legal", :new=>"banned"},
        {:name=>"Seat of the Synod", :old=>"legal", :new=>"banned"},
        {:name=>"Sensei's Divining Top", :old=>"legal", :new=>"banned"},
        {:name=>"Skullclamp", :old=>"legal", :new=>"banned"},
        {:name=>"Stoneforge Mystic", :old=>"legal", :new=>"banned"},
        {:name=>"Sword of the Meek", :old=>"legal", :new=>"banned"},
        {:name=>"Tree of Tales", :old=>"legal", :new=>"banned"},
        {:name=>"Umezawa's Jitte", :old=>"legal", :new=>"banned"},
        {:name=>"Valakut, the Molten Pinnacle", :old=>"legal", :new=>"banned"},
        {:name=>"Vault of Whispers", :old=>"legal", :new=>"banned"},
      ]],
    ])
  end

  ## Commander

  it "commander" do
    assert_legality "commander", Date.parse("2005.1.1"), "Zodiac Dog", nil
    assert_legality "commander", Date.parse("2006.1.1"), "Zodiac Dog", "legal"
  end

  ## Other formats

  it "pauper" do
    assert_legality "pauper", "rav", "Blazing Torch", nil
    assert_legality "pauper", "zen", "Blazing Torch", nil
    assert_legality "pauper", "isd", "Blazing Torch", "legal"

    assert_legality "vintage", "rav", "Blazing Torch", nil
    assert_legality "vintage", "zen", "Blazing Torch", "legal"
    assert_legality "vintage", "isd", "Blazing Torch", "legal"
  end

  # We don't have all historical legality for Duel Commander yet,
  # maybe add it at some later point
  it "duel commander" do
    assert_count_results 'banned:"duel commander"', 60
    assert_count_results 'restricted:"duel commander"', 14
  end

  # We don't keep historical legality for Petty Dreadful yet
  it "penny dreadful" do
    assert_search_include 'f:"penny dreadful"', *FormatPennyDreadful::PrimaryCards
    # If card is in Penny Dreadful, its other side is as well
    # (except for meld cards)
    assert_search_results "f:pd other:-f:pd -is:meld"
    # If AB in PD, but A not in PD, then fail
    assert_search_results "is:meld not:primary f:pd other:-f:pd"
    # If AB not in PD, but A and B both PD, then fail
    assert_search_results "is:meld not:primary -f:pd -other:-f:pd"
  end

  ## TODO - Extended, and various weirdo formats
end
