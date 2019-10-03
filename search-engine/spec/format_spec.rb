describe "Formats" do
  include_context "db"

  ## General queries

  it "formats" do
    assert_search_equal "f:standard", "legal:standard"
    assert_search_results "f:extended" # Does not exist according to mtgjson
    assert_search_equal_cards "f:standard",
      %Q[e:grn,rna,war,m20,eld]
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
    FormatModern.new.ban_events.should eq([
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
    assert_count_cards 'banned:"duel commander"', 62
    assert_count_cards 'restricted:"duel commander"', 19
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

  ## TODO - Extended, and various weirdo formats
end
