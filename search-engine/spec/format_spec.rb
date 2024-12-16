describe "Formats" do
  include_context "db"

  ## General queries

  it "formats" do
    assert_search_equal "f:standard", "legal:standard"
    assert_search_results "f:extended" # Does not exist according to mtgjson
    assert_search_equal_cards "f:standard",
      %[
        e:dmu,bro,one,mom,mat,woe,lci,mkm,otj,big,blb,dsk,fdn
        -(The Meathook Massacre)
        -(Invoke Despair)
        -(Fable of the Mirror-Breaker)
        -(Reflection of Kiki-Jiki)
        -(Reckoner Bankbuster)
        -is:alchemy
      ]
    assert_search_equal_cards 'f:"ravnica block"', "e:rav,gp,di"
    assert_search_equal 'f:"ravnica block"', 'legal:"ravnica block"'
    assert_search_equal_cards 'f:"ravnica block"', 'b:ravnica'
    assert_search_differ_cards 'f:"mirrodin block" t:land', 'b:"mirrodin" t:land'
    assert_search_equal "f:duel", 'f:"duel commander"'
    assert_search_equal "f:penny", 'f:"penny dreadful"'
  end

  it "ban_events" do
    FormatInnistradBlock.new.ban_events.should eq([
      [Date.parse("2012-04-01"),
        "https://magic.wizards.com/en/articles/archive/feature/march-20-2012-dci-banned-restricted-list-announcement-2012-03-20",
      [
        {name: "Intangible Virtue", old: "legal", new: "banned"},
        {name: "Lingering Souls", old: "legal", new: "banned"},
      ]],
    ])
    # cutting it so it doesn't need endless manual updates
    FormatModern.new.ban_events.last(24).should eq([
      [Date.parse("2024-08-26"),
       "https://magic.wizards.com/en/news/announcements/august-26-2024-banned-and-restricted-announcement",
      [
        {:name=>"Nadu, Winged Wisdom", :new=>"banned", :old=>"legal"},
        {:name=>"Grief", :new=>"banned", :old=>"legal"}
      ]],
      [Date.parse("2023-12-04"),
        "https://magic.wizards.com/en/news/announcements/december-4-2023-banned-and-restricted-announcement",
      [
          {:name=>"Fury", :new=>"banned", :old=>"legal"},
          {:name=>"Up the Beanstalk", :new=>"banned", :old=>"legal"},
      ]],
      [Date.parse("2023-08-07"),
        "https://magic.wizards.com/en/news/announcements/august-7-2023-banned-and-restricted-announcement",
        [
          {:name=>"Preordain", :new=>"legal", :old=>"banned"},
      ]],
      [Date.parse("2022-10-10"),
        "https://magic.wizards.com/en/articles/archive/news/october-10-2022-banned-and-restricted-announcement",
      [
        {name: "Yorion, Sky Nomad", old: "legal", new: "banned"},
      ]],
      [Date.parse("2022-03-07"),
        "https://magic.wizards.com/en/articles/archive/news/march-7-2022-banned-and-restricted-announcement",
      [
        {:name=>"Lurrus of the Dream-Den", :new=>"banned", :old=>"legal"},
      ]],
      [Date.parse("2021-02-15"),
        "https://magic.wizards.com/en/articles/archive/news/february-15-2021-banned-and-restricted-announcement",
      [
        {:name=>"Field of the Dead", :new=>"banned", :old=>"legal"},
        {:name=>"Mystic Sanctuary", :new=>"banned", :old=>"legal"},
        {:name=>"Simian Spirit Guide", :new=>"banned", :old=>"legal"},
        {:name=>"Tibalt's Trickery", :new=>"banned", :old=>"legal"},
        {:name=>"Uro, Titan of Nature's Wrath", :new=>"banned", :old=>"legal"}
      ]],
      [Date.parse("2020-07-13"),
        "https://magic.wizards.com/en/articles/archive/news/july-13-2020-banned-and-restricted-announcement-2020-07-13",
      [
        {:name=>"Arcum's Astrolabe", :new=>"banned", :old=>"legal"},
      ]],
      [Date.parse("2020-03-10"),
        "https://magic.wizards.com/en/articles/archive/news/march-9-2020-banned-and-restricted-announcement",
      [
        {:name=>"Once Upon a Time", :new=>"banned", :old=>"legal"},
      ]],
      [Date.parse("2020-01-14"),
        "https://magic.wizards.com/en/articles/archive/news/january-13-2020-banned-and-restricted-announcement",
      [
        {:name=>"Mox Opal", :new=>"banned", :old=>"legal"},
        {:name=>"Oko, Thief of Crowns", :new=>"banned", :old=>"legal"},
        {:name=>"Mycosynth Lattice", :new=>"banned", :old=>"legal"},
      ]],
      [Date.parse("2019-08-30"),
        "https://magic.wizards.com/en/articles/archive/news/august-26-2019-banned-and-restricted-announcement-2019-08-26",
      [
        {:name=>"Stoneforge Mystic", :new=>"legal", :old=>"banned"},
        {:name=>"Hogaak, Arisen Necropolis", :new=>"banned", :old=>"legal"},
        {:name=>"Faithless Looting", :new=>"banned", :old=>"legal"},
      ]],
      [Date.parse("2019-07-12"),
        "https://magic.wizards.com/en/articles/archive/news/july-8-2019-banned-and-restricted-announcement-2019-07-08",
      [
        {:name=>"Bridge from Below", :new=>"banned", :old=>"legal"},
      ]],
      [Date.parse("2019-01-21"),
        "https://magic.wizards.com/en/articles/archive/news/january-21-2019-banned-and-restricted-announcement",
      [
        {:name=>"Krark-Clan Ironworks", :new=>"banned", :old=>"legal"},
      ]],
      [Date.parse("2018-02-19"),
        "https://magic.wizards.com/en/articles/archive/news/february-12-2018-banned-and-restricted-announcement-2018-02-12",
      [
        {:name=>"Jace, the Mind Sculptor", :old=>"banned", :new=>"legal"},
        {:name=>"Bloodbraid Elf", :old=>"banned", :new=>"legal"},
      ]],
      [Date.parse("2017-01-20"),
        "https://magic.wizards.com/en/articles/archive/news/january-9-2017-banned-and-restricted-announcement-2017-01-09",
      [
        {:name=>"Golgari Grave-Troll", :old=>"legal", :new=>"banned"},
        {:name=>"Gitaxian Probe", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2016-04-08"),
        "https://magic.wizards.com/en/articles/archive/news/banned-and-restricted-announcement-2016-04-04",
      [
        {:name=>"Ancestral Vision", :old=>"banned", :new=>"legal"},
        {:name=>"Sword of the Meek", :old=>"banned", :new=>"legal"},
        {:name=>"Eye of Ugin", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2016-01-22"),
        "https://magic.wizards.com/en/articles/archive/news/january-18-2016-banned-and-restricted-announcement-2016-01-18",
      [
        {:name=>"Splinter Twin", :old=>"legal", :new=>"banned"},
        {:name=>"Summer Bloom", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2015-01-23"),
        "https://magic.wizards.com/en/articles/archive/feature/banned-and-restricted-announcement-2015-01-19",
      [
        {:name=>"Golgari Grave-Troll", :old=>"banned", :new=>"legal"},
        {:name=>"Birthing Pod", :old=>"legal", :new=>"banned"},
        {:name=>"Dig Through Time", :old=>"legal", :new=>"banned"},
        {:name=>"Treasure Cruise", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2014-02-07"),
        "https://magic.wizards.com/en/articles/archive/top-decks/february-3-2014-dci-banned-restricted-list-announcement-2014-02-03",
      [
        {:name=>"Bitterblossom", :old=>"banned", :new=>"legal"},
        {:name=>"Wild Nacatl", :old=>"banned", :new=>"legal"},
        {:name=>"Deathrite Shaman", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2013-05-03"),
        "https://magic.wizards.com/en/articles/archive/feature/banned-and-restricted-2013-04-22-0",
      [
        {:name=>"Second Sunrise", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2013-02-01"),
        "https://magic.wizards.com/en/articles/archive/january-28-2013-dci-banned-restricted-list-announcement-2013-01-28",
      [
        {:name=>"Bloodbraid Elf", :old=>"legal", :new=>"banned"},
        {:name=>"Seething Song", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2012-10-01"),
        "https://magic.wizards.com/en/articles/archive/feature/september-20-2012-dci-banned-restricted-list-announcement-2012-09-20",
      [
        {:name=>"Valakut, the Molten Pinnacle", :old=>"banned", :new=>"legal"},
      ]],
      [Date.parse("2012-01-01"),
        "https://magic.wizards.com/en/articles/archive/feature/december-20-2011-dci-banned-restricted-list-announcement-2011-12-20",
      [
        {:name=>"Punishing Fire", :old=>"legal", :new=>"banned"},
        {:name=>"Wild Nacatl", :old=>"legal", :new=>"banned"},
      ]],
      [Date.parse("2011-10-01"),
        "https://magic.wizards.com/en/articles/archive/feature/september-20-2011-dci-banned-restricted-list-announcement-2011-09-20",
      [
        {:name=>"Blazing Shoal", :old=>"legal", :new=>"banned"},
        {:name=>"Cloudpost", :old=>"legal", :new=>"banned"},
        {:name=>"Green Sun's Zenith", :old=>"legal", :new=>"banned"},
        {:name=>"Ponder", :old=>"legal", :new=>"banned"},
        {:name=>"Preordain", :old=>"legal", :new=>"banned"},
        {:name=>"Rite of Flame", :old=>"legal", :new=>"banned"},
      ]],
      [nil,
        "https://magic.wizards.com/en/articles/archive/latest-developments/welcome-modern-world-2011-08-12",
      [
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
    assert_count_cards 'banned:"duel commander"', 94
    assert_count_cards 'restricted:"duel commander"', 29
  end

  # Used to be Lurrus
  # And now it's all the sticker and attraction cards, and I don't even know if the format is still used or not really
  # it "mtgo commander" do
  #   assert_count_cards 'banned:vintage legal:"mtgo commander"', 0
  # end

  it "historic" do
    # including STA pre-banned
    # this is extra fun as some conjurable cards will be not banned
    assert_count_cards "banned:historic", 27
    assert_legality "historic", Date.parse("2023-08-01"), "Alora, Cheerful Assassin", "restricted"
    assert_legality "historic", Date.parse("2023-08-01"), "Black Lotus", "restricted"
    assert_legality "historic", Date.parse("2023-08-01"), "Lightning Bolt", "restricted"
  end

  it "premodern" do
    assert_count_cards "banned:premodern", 32
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

  describe "can check PhysicalCard or CardPrinting" do
    let(:not_in_format) { db.search("Adorable Kitten").printings.first }
    let(:banned) { db.search("Contract from Below").printings.first }
    let(:restricted) { db.search("Black Lotus" ).printings.first}
    let(:legal) { db.search("Giant Spider").printings.first }
    let(:vintage) { FormatVintage.new }

    it do
      [not_in_format, banned, restricted, legal].each do |c|
        vintage.legality(c).should eq vintage.legality(PhysicalCard.for(c))
      end
    end
  end

  ## Wildcards

  it "banned:*" do
    # This can be a long list
    assert_search_equal "banned:*", %[
      banned:standard or
      banned:pioneer or
      banned:modern or
      banned:legacy or
      banned:commander or
      banned:pauper or
      banned:duel or
      banned:brawl or
      banned:historic or
      banned:"Mirrodin Block" or
      banned:"Urza Block" or
      banned:"Ice Age Block" or
      banned:"Masques Block" or
      banned:"Mirage Block" or
      banned:"Innistrad Block" or
      banned:"Tempest Block" or
      banned:"MTGO Commander" or
      banned:premodern
    ]
  end

  it "restricted:*" do
    assert_search_equal "restricted:*", "restricted:vintage or restricted:duel or restricted:unsets or restricted:historic or restricted:alchemy"
  end

  it "legal:*" do
    assert_search_equal "legal:*", %[
      legal:vintage or
      legal:unsets or
      legal:historic or
      legal:commander or
      legal:"Urza Block" or
      legal:penny or
      legal:duel or
      legal:premodern
    ]
  end

  it "format:*" do
    assert_search_equal "format:*", "legal:* or restricted:*"
  end

  it "restricted:* time:nph" do
    assert_search_include "restricted:* time:rtr", "Thirst for Knowledge"
    assert_search_exclude "restricted:* time:war", "Thirst for Knowledge"
  end

  it "banned:* time:nph" do
    assert_search_exclude "banned:* time:rtr", "Splinter Twin"
    assert_search_include "banned:* time:war", "Splinter Twin"
  end

  it "racist cards are banned in all official formats" do
    assert_search_results "is:racist f:legacy"
    assert_search_results "is:racist f:vintage"
    assert_search_results "is:racist f:pauper"
    assert_search_results "is:racist f:modern"
    assert_search_results "is:racist f:commander"
    assert_search_results "is:racist f:\"mtgo commander\""
    assert_search_results "is:racist f:pioneer"
    assert_search_results "is:racist f:standard"
  end

  it "alchemy follows standard plus appropriate Y* sets" do
    standard_set_codes = FormatStandard.new.included_sets
    alchemy_set_codes = FormatAlchemy.new.included_sets
    standard_set_codes.each do |code|
      alchemy_set_codes.include?(code).should(be_truthy, "Alchemy should include #{code} since Standard includes #{code}")
      alchemy_code = "y#{code}"
      next unless db.sets[alchemy_code]
      alchemy_set_codes.include?(alchemy_code).should(be_truthy, "Alchemy should include #{alchemy_code} since Standard includes #{code}")
    end
  end
end
