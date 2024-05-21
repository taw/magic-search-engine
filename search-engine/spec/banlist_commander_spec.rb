describe "Banlist" do
  include_context "db"

# Based on:
# http://www.mtgsalvation.com/forums/the-game/commander-edh/204244-edh-banlist-timeline
# except most recent ones where most recent announcements are explicitly linked

  def assert_commander_banlist_changes(date, *changes)
    assert_banlist_changes(
      date,
      *changes.each_slice(2).flat_map{|s,c|
        ["commander #{s}", c]
      }
    )
  end

  # this used to be the case but isn't anymore
  it "vintage banned means commander banned" do
    BanList.all_change_dates.each do |date|
      vintage_banlist  = BanList["vintage"].full_ban_list(date)
      commander_banlist = BanList["commander"].full_ban_list(date)

      vintage_banned = vintage_banlist.select{|c,s| s == "banned"}.map(&:first)
      commander_banned = commander_banlist.select{|c,s| s == "banned"}.map(&:first)

      vintage_only_banned = vintage_banned - commander_banned

      if date >= Date.parse("2020-05-18") and date < Date.parse("2021-02-15")
        # for a while the exception was Lurrus
        vintage_only_banned.should eq(["Lurrus of the Dream-Den"])
      elsif date < Date.parse("2024-05-13")
        vintage_only_banned.should eq([])
      else
        # Stickers and Attractions
        # vintage_only_banned.should eq([*sticker_cards, *attraction_cards])
      end
    end
  end

  it "2019" do
    assert_commander_banlist_changes "July 2019",
      "banned", "Paradox Engine",
      "banned", "Iona, Shield of Emeria",
      "unbanned", "Painter's Servant"
  end

 it "2017" do
    assert_commander_banlist_changes "April 2017",
      "banned", "Leovold, Emissary of Trest",
      "unbanned", "Protean Hulk"
  end

  it "2016" do
    assert_commander_banlist_changes "January 2016",
      "banned", "Prophet of Kruphix"
  end

  it "2015" do
    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=17890
    assert_commander_banlist_changes "September 2015" # no changes
    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=17774
    assert_commander_banlist_changes "July 2015" # no changes
    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=17560
    assert_commander_banlist_changes "March 2015" # no changes
    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=17451
    assert_commander_banlist_changes "January 2015" # no changes
  end

  it "2014" do
    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=17210
    assert_commander_banlist_changes "September 2014",
      "restricted-to-banned", "Braids, Cabal Minion",
      "restricted-to-banned", "Rofellos, Llanowar Emissary",
      "restricted-to-banned", "Erayo, Soratami Ascendant",
      "unrestricted", "Kokusho, the Evening Star",
      "unbanned", "Metalworker"

    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=17093
    assert_commander_banlist_changes "July 2014" # no changes

    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=16940
    assert_commander_banlist_changes "April 2014" # no changes

    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=16697
    assert_commander_banlist_changes "February 2014",
      "banned", "Sylvan Primordial"
  end

  it "2013" do
    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=16212
    assert_commander_banlist_changes "September 2013" # no changes
    #  http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=15972
    assert_commander_banlist_changes "July 2013"

    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=15735
    assert_commander_banlist_changes "April 2013",
      "banned",   "Trade Secrets",
      "unbanned", "Staff of Domination"

    # http://www.mtgcommander.net/Forum/viewtopic.php?f=1&t=15321
    assert_commander_banlist_changes "January 2013"
  end

  it "2012" do
    assert_commander_banlist_changes "September 2012",
      "banned", "Primeval Titan",
      "banned", "Worldfire",
      "banned-to-restricted", "Kokusho, the Evening Star"

    assert_commander_banlist_changes "June 2012",
      "banned", "Griselbrand",
      "banned", "Sundering Titan"
  end

  it "2011" do
    assert_commander_banlist_changes "September 2011",
      "restricted", "Erayo, Soratami Ascendant",
      "unbanned", "Lion's Eye Diamond"
      # Specifically banned even though it's redundant due to vintage ban
      # "banned", "Shahrazad"

    assert_commander_banlist_changes "June 2011",
      "unbanned", "Worldgorger Dragon"
  end

  it "2010" do
    assert_commander_banlist_changes "December 2010",
      "banned", "Emrakul, the Aeons Torn"

    assert_commander_banlist_changes "June 2010",
      "banned", "Channel",
      "banned", "Staff of Domination",
      "banned", "Tolarian Academy",
      "restricted", "Rofellos, Llanowar Emissary"
  end

  it "2009" do
    assert_commander_banlist_changes "December 2009",
      "unbanned", "Grindstone",
      "banned", "Painter's Servant"

    assert_commander_banlist_changes "September 2009",
      "unbanned", "Riftsweeper"

    assert_commander_banlist_changes "June 2009",
      "banned", "Fastbond",
      "banned", "Gifts Ungiven",
      "restricted", "Braids, Cabal Minion"

    assert_commander_banlist_changes "March 2009",
      "banned", "Metalworker",
      "banned", "Tinker",
      "unbanned", "Crucible of Worlds",
      "unrestricted", "Rofellos, Llanowar Emissary"
  end

  it "2008" do
    assert_commander_banlist_changes "December 2008",
      "banned", "Time Vault"

    assert_commander_banlist_changes "September 2008",
      "banned", "Grindstone",
      "banned", "Karakas",
      "banned", "Lion's Eye Diamond",
      "banned", "Protean Hulk",
      "banned", "Riftsweeper",
      "unbanned", "Test of Endurance"

    assert_commander_banlist_changes "June 2008",
      "banned", "Limited Resources"

    assert_commander_banlist_changes "February 2008",
      "banned", "Recurring Nightmare",
      "banned", "Kokusho, the Evening Star"
  end

  it "2007" do
    # So it says, but there's no unban announcement
    # assert_commander_banlist_changes "November 2007",
      # "unbanned", "Beacon of Immortality"

    # Shahrazad removed from the banned list (but still de facto banned, since it's banned in Vintage).
    assert_commander_banlist_changes "September 2007"

    assert_commander_banlist_changes "March 2007",
      "banned", "Coalition Victory",
      "restricted", "Rofellos, Llanowar Emissary"
  end

  it "2006" do
    assert_commander_banlist_changes "November 2006",
      "unrestricted", "Niv-Mizzet, the Firemind",
      "unrestricted", "Heartless Hidetsugu"
      # No evidence it was actually restricted ever...
      # "unrestricted", "Kaervek the Merciless",

    assert_commander_banlist_changes "May 2006",
      "banned", "Yawgmoth's Bargain"

    assert_commander_banlist_changes "February 2006",
      "restricted", "Niv-Mizzet, the Firemind",
      "restricted", "Heartless Hidetsugu"
  end

  it "2005" do
    assert_commander_banlist_changes "April 2005",
      "banned", "Ancestral Recall",
      "banned", "Balance",
      "banned", "Black Lotus",
      "banned", "Biorhythm",
      "banned", "Library of Alexandria",
      "banned", "Mox Emerald",
      "banned", "Mox Jet",
      "banned", "Mox Pearl",
      "banned", "Mox Ruby",
      "banned", "Mox Sapphire",
      "banned", "Panoptic Mirror",
      "banned", "Sway of the Stars",
      "banned", "Time Walk",
      "banned", "Upheaval",
      "banned", "Worldgorger Dragon"

     assert_commander_banlist_changes "December 2005",
      "banned", "Crucible of Worlds",
      "banned", "Shahrazad"
  end

  it "2004" do
    assert_commander_banlist_changes "October 2004",
      "unbanned", "Burning Wish",
      "unbanned", "Cunning Wish",
      "unbanned", "Death Wish",
      "unbanned", "Enlightened Tutor",
      "unbanned", "Living Wish"
      # No announcement actually banning it, presumably banned with wishes?
      # "unbanned", "Ring of Ma'ruf"
  end

  it "2003" do
    assert_commander_banlist_changes "May 2003",
      "banned", "Burning Wish",
      "banned", "Cunning Wish",
      "banned", "Death Wish",
      "banned", "Enlightened Tutor",
      "banned", "Living Wish"
  end

  it "2002" do
    # TODO:
    # Initial banlist
    # October 2002
    # Collector's Edition, "Promotional cards", poker cards and silver-bordered cards are banned. (I'm assuming poker cards are the 52-card, Magic-backed standard playing-card decks given to early DCI members.)
    # Unique Portal and Starter cards are banned. (This means Portal and Starter cards that don't share a name with "standard" Magic cards.)
    # Vintage-illegal cards are banned.
    # Test of Endurance is banned.

    # It's format start, not change...
    assert_commander_banlist_changes "October 2002",
      "banned", "Test of Endurance"
  end
end
