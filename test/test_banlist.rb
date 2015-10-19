require_relative "test_helper"

class BanlistTest < Minitest::Test
  def setup
    @db = load_database
    @ban_list = BanList.new
  end

  def find_set_change_at_date(date)
    date = Date.parse("#{date}")
    @regular_sets ||= @db.sets.values.select(&:regular?).sort_by(&:release_date)
    prev_set = @regular_sets.select{|set| set.release_date < date}.max_by(&:release_date).set_code
    this_set = @regular_sets.select{|set| set.release_date >= date}.min_by(&:release_date).set_code
    [prev_set, this_set]
  end

  def assert_hash_equal(h1, h2, *msg)
    # Surely there oucht to be a plugin which fixes that, right?
    assert_equal(
      h1.sort.map{|k,v| "#{k} #{v}\n"}.join,
      h2.sort.map{|k,v| "#{k} #{v}\n"}.join,
      *msg
    )
  end

  def assert_banlist_status(date, format, expected_legality, card_name)
    if date.is_a?(Date)
      dsc = "#{date}"
      set_date = date
    else
      dsc = "#{set} (#{set_date})"
      set_date = @db.sets[set].release_date
    end
    card = @db.cards[card_name]
    actual_legality = @ban_list.legality(format, card_name, set_date) || "legal"
    assert_equal expected_legality, actual_legality, "Legality of #{card_name} in #{format} during #{dsc}"
  end

  def assert_banlist_change(prev_date, this_date, format, change, card)
    if format == "vintage+"
      change_legacy = change
      case change
      when "banned", "restricted"
        change_legacy = "banned"
      when "unbanned", "unrestricted"
        change_legacy = "unbanned"
      when "banned-to-restricted", "restricted-to-banned"
        change_legacy = nil
      else
        raise
      end
      assert_banlist_change(prev_date, this_date, "vintage", change, card)
      assert_banlist_change(prev_date, this_date, "legacy", change_legacy, card) if change_legacy
      return
    end

    case change
    when "banned"
      assert_banlist_status(prev_date, format, "legal", card)
      assert_banlist_status(this_date, format, "banned", card)
    when "unbanned"
      assert_banlist_status(prev_date, format, "banned", card)
      assert_banlist_status(this_date, format, "legal", card)
    when "restricted"
      assert_banlist_status(prev_date, format, "legal", card)
      assert_banlist_status(this_date, format, "restricted", card)
    when "unrestricted"
      assert_banlist_status(prev_date, format, "restricted", card)
      assert_banlist_status(this_date, format, "legal", card)
    when "banned-to-restricted"
      assert_banlist_status(prev_date, format, "banned", card)
      assert_banlist_status(this_date, format, "restricted", card)
    when "restricted-to-banned"
      assert_banlist_status(prev_date, format, "restricted", card)
      assert_banlist_status(this_date, format, "banned", card)
    else
      require 'pry'; binding.pry
    end
  end

  def assert_banlist_changes_by_set(date, *changes)
    prev_set, this_set = find_set_change_at_date(date)
    changes.each_slice(2) do |change, card|
      raise unless change =~ /\A(.*) (\S+)\z/
      assert_banlist_change prev_set, this_set, $1, $2, card
    end
  end

  def assert_banlist_changes(date, *changes)
    prev_date = Date.parse(date)
    this_date = (prev_date >> 1) + 5
    changes.each_slice(2) do |change, card|
      raise unless change =~ /\A(.*) (\S+)\z/
      assert_banlist_change prev_date, this_date, $1, $2, card
    end
  end

  def assert_full_banlist(format, time, banned_cards, restricted_cards=[])
    time = Date.parse(time)
    expected_banlist = Hash[
      banned_cards.map{|c| [c, "banned"]} +
      restricted_cards.map{|c| [c, "restricted"]}
    ]
    actual_banlist = @ban_list.full_ban_list(format, time)
    assert_hash_equal expected_banlist, actual_banlist, "Full banlist for #{format} at #{time}"
  end

  # Based on:
  # http://mtgsalvation.gamepedia.com/Timeline_of_DCI_bans_and_restrictions#2015

  def test_banlist_2015
    assert_banlist_changes "September 2015",
      "legacy banned",  "Dig Through Time",
      "legacy unbanned", "Black Vise",
      "vintage restricted", "Chalice of the Void",
      "vintage unrestricted", "Thirst for Knowledge"
    assert_banlist_changes "March 2015",
      "pauper banned", "Treasure Cruise"
    assert_banlist_changes "January 2015",
      "modern banned", "Dig Through Time",
      "modern banned", "Treasure Cruise",
      "modern banned", "Birthing Pod",
      "legacy banned", "Treasure Cruise",
      "legacy unbanned", "Worldgorger Dragon",
      "vintage restricted", "Treasure Cruise",
      "vintage unrestricted", "Gifts Ungiven"
  end

  def test_banlist_2014
    assert_banlist_changes "February 2014",
      "modern banned", "Deathrite Shaman",
      "modern unbanned", "Wild Nacatl",
      "modern unbanned", "Bitterblossom"
  end

  def test_banlist_2013
    assert_banlist_changes "September 2013",
      "pauper banned", "Cloudpost",
      "pauper banned", "Temporal Fissure"
    assert_banlist_changes "May 2013",
      "modern banned", "Second Sunrise",
      "vintage unrestricted", "Regrowth"
    assert_banlist_changes "January 2013",
      "modern banned", "Bloodbraid Elf",
      "modern banned", "Seething Song",
      "pauper banned", "Empty the Warrens",
      "pauper banned", "Grapeshot",
      "pauper banned", "Invigorate"
  end

  def test_banlist_2012
    assert_banlist_changes "September 2012",
      "modern unbanned", "Valakut, the Molten Pinnacle",
      "vintage unrestricted", "Burning Wish"
    assert_banlist_changes "June 2012",
      "legacy unbanned", "Land Tax"
    assert_banlist_changes "March 2012",
      "innistrad block banned", "Lingering Souls",
      "innistrad block banned", "Intangible Virtue"
  end

  def test_banlist_2011
    # Weirdo exception for "War of Attrition" event deck ignored
    assert_banlist_changes "June 2011",
      "standard banned", "Jace, the Mind Sculptor",
      "standard banned", "Stoneforge Mystic"
    assert_banlist_changes "September 2011",
      "extended banned", "Jace, the Mind Sculptor",
      "extended banned", "Mental Misstep",
      "extended banned", "Ponder",
      "extended banned", "Preordain",
      "extended banned", "Stoneforge Mystic",
      "legacy banned", "Mental Misstep",
      "vintage unrestricted", "Fact or Fiction",
      "modern banned", "Blazing Shoal",
      "modern banned", "Cloudpost",
      "modern banned", "Green Sun's Zenith",
      "modern banned", "Ponder",
      "modern banned", "Preordain",
      "modern banned", "Rite of Flame"
    assert_banlist_changes "December 2011",
      "modern banned", "Punishing Fire",
      "modern banned", "Wild Nacatl"
  end

  def test_initial_modern_banlist
    # August 2011
    assert_full_banlist "modern", "August 2011", [
      "Ancestral Vision",
      "Ancient Den",
      "Bitterblossom",
      "Chrome Mox",
      "Dark Depths",
      "Dread Return",
      "Glimpse of Nature",
      "Golgari Grave-Troll",
      "Great Furnace",
      "Hypergenesis",
      "Jace, the Mind Sculptor",
      "Mental Misstep",
      "Seat of the Synod",
      "Sensei's Divining Top",
      "Skullclamp",
      "Stoneforge Mystic",
      "Sword of the Meek",
      "Tree of Tales",
      "Umezawa's Jitte",
      "Valakut, the Molten Pinnacle",
      "Vault of Whispers",
    ]
  end

  def test_banlist_2010
    assert_banlist_changes "June 2010",
      "extended banned", "Sword of the Meek",
      "extended banned", "Hypergenesis",
      "legacy banned", "Mystical Tutor",
      "legacy unbanned", "Grim Monolith",
      "legacy unbanned", "Illusionary Mask"
    assert_banlist_changes "September 2010",
      "vintage unrestricted", "Frantic Search",
      "vintage unrestricted", "Gush"
    assert_banlist_changes "December 2010",
      "legacy banned", "Survival of the Fittest",
      "legacy unbanned", "Time Spiral"
  end

  def test_banlist_2009
    assert_banlist_changes "June 2009",
      "vintage restricted", "Thirst for Knowledge",
      "vintage unrestricted", "Crop Rotation",
      "vintage unrestricted", "Enlightened Tutor",
      "vintage unrestricted", "Entomb",
      "vintage unrestricted", "Grim Monolith"
    assert_banlist_changes "September 2009",
      "legacy unbanned", "Dream Halls",
      "legacy unbanned", "Entomb",
      "legacy unbanned", "Metalworker"
  end

  def test_banlist_2008
    assert_banlist_changes "June 2008",
      "vintage restricted", "Brainstorm",
      "vintage restricted", "Flash",
      "vintage restricted", "Gush",
      "vintage restricted", "Merchant Scroll",
      "vintage restricted", "Ponder"
    assert_banlist_changes "September 2008",
      "extended banned", "Sensei's Divining Top",
      "legacy banned", "Time Vault",
      "vintage restricted", "Time Vault",
      "vintage unrestricted", "Chrome Mox",
      "vintage unrestricted", "Dream Halls",
      "vintage unrestricted", "Mox Diamond",
      "vintage unrestricted", "Personal Tutor",
      "vintage unrestricted", "Time Spiral"
  end

  def test_banlist_2007
    assert_banlist_changes "June 2007",
      "vintage restricted", "Gifts Ungiven",
      "vintage unrestricted", "Voltaic Key",
      "vintage unrestricted", "Black Vise",
      "vintage unrestricted", "Mind Twist",
      "vintage unrestricted", "Gush",
      "legacy banned", "Flash",
      "legacy unbanned", "Mind Over Matter",
      "legacy unbanned", "Replenish"

    assert_banlist_changes "September 2007",
      "vintage banned", "Shahrazad",
      "legacy banned", "Shahrazad"
  end

  def test_banlist_2006
    assert_banlist_changes "March 2006",
      "mirrodin block banned", "Aether Vial",
      "mirrodin block banned", "Ancient Den",
      "mirrodin block banned", "Arcbound Ravager",
      "mirrodin block banned", "Darksteel Citadel",
      "mirrodin block banned", "Disciple of the Vault",
      "mirrodin block banned", "Great Furnace",
      "mirrodin block banned", "Seat of the Synod",
      "mirrodin block banned", "Tree of Tales",
      "mirrodin block banned", "Vault of Whispers"
  end

  def test_banlist_2005
    assert_banlist_changes "March 2005",
      "standard banned", "Arcbound Ravager",
      "standard banned", "Disciple of the Vault",
      "standard banned", "Darksteel Citadel",
      "standard banned", "Ancient Den",
      "standard banned", "Great Furnace",
      "standard banned", "Seat of the Synod",
      "standard banned", "Tree of Tales",
      "standard banned", "Vault of Whispers",
      "vintage restricted", "Trinisphere"

    assert_banlist_changes "September 2005",
      "extended banned", "Aether Vial",
      "extended banned", "Disciple of the Vault",
      "legacy banned", "Imperial Seal",
      "vintage restricted", "Imperial Seal",
      "vintage restricted", "Personal Tutor",
      "vintage unrestricted", "Mind Over Matter",
      "two-headed giant banned", "Erayo, Soratami Ascendant"
  end

  def test_banlist_2004
    assert_banlist_changes "June 2004",
      "standard banned", "Skullclamp",
      "mirrodin block banned", "Skullclamp"

    assert_banlist_changes "September 2004",
      "extended banned", "Metalworker",
      "extended banned", "Skullclamp",
      "vintage unrestricted", "Braingeyser",
      "vintage unrestricted", "Doomsday",
      "vintage unrestricted", "Earthcraft",
      # "vintage unrestricted", "Fork",
      # In September 2004 Legacy becomes independent of Vintage
      "legacy unbanned", "Braingeyser",
      "legacy unbanned", "Burning Wish",
      "legacy unbanned", "Chrome Mox",
      "legacy unbanned", "Crop Rotation",
      "legacy unbanned", "Doomsday",
      "legacy unbanned", "Enlightened Tutor",
      "legacy unbanned", "Fact or Fiction",
      # "legacy unbanned", "Fork",
      "legacy unbanned", "Lion's Eye Diamond",
      "legacy unbanned", "Lotus Petal",
      "legacy unbanned", "Mox Diamond",
      "legacy unbanned", "Mystical Tutor",
      "legacy unbanned", "Regrowth",
      "legacy unbanned", "Stroke of Genius",
      "legacy unbanned", "Voltaic Key",
      "legacy banned", "Bazaar of Baghdad",
      "legacy banned", "Goblin Recruiter",
      "legacy banned", "Hermit Druid",
      "legacy banned", "Illusionary Mask",
      "legacy banned", "Land Tax",
      "legacy banned", "Mana Drain",
      "legacy banned", "Metalworker",
      "legacy banned", "Mishra's Workshop",
      "legacy banned", "Oath of Druids",
      "legacy banned", "Replenish",
      "legacy banned", "Skullclamp",
      "legacy banned", "Worldgorger Dragon"

    assert_banlist_changes "December 2004",
      "vintage unrestricted", "Stroke of Genius"
  end

  def test_banlist_2003
    assert_banlist_changes "March 2003",
      "vintage+ unrestricted", "Berserk",
      "vintage+ unrestricted", "Hurkyl's Recall",
      # "vintage+ unrestricted", "Recall" ,
      "vintage+ restricted", "Earthcraft",
      "vintage+ restricted", "Entomb"

    assert_banlist_changes "June 2003",
      "vintage+ restricted", "Gush",
      "vintage+ restricted", "Mind's Desire"

    assert_banlist_changes "September 2003",
      "extended banned", "Goblin Lackey",
      "extended banned", "Entomb",
      "extended banned", "Frantic Search"

    assert_banlist_changes "December 2003",
      "extended banned", "Goblin Recruiter",
      "extended banned", "Grim Monolith",
      "extended banned", "Tinker",
      "extended banned", "Hermit Druid",
      "extended banned", "Ancient Tomb",
      "extended banned", "Oath of Druids",
      "vintage+ restricted", "Burning Wish",
      "vintage+ restricted", "Chrome Mox",
      "vintage+ restricted", "Lion's Eye Diamond"
  end

  def test_banlist_2002
    # No changes whole year
  end

  def test_banlist_2001
    assert_banlist_changes "March 2001",
      "extended banned", "Necropotence",
      "extended banned", "Replenish",
      "extended banned", "Survival of the Fittest",
      "extended banned", "Demonic Consultation"

    assert_banlist_changes "December 2001",
      "vintage+ restricted", "Fact or Fiction"
  end

  def test_banlist_2000
    assert_banlist_changes "March 2000",
      "extended banned", "Dark Ritual",
      "extended banned", "Mana Vault"

    assert_banlist_changes "June 2000",
      "masques block banned", "Lin Sivvi, Defiant Hero",
      "masques block banned", "Rishadan Port"

    assert_banlist_changes "September 2000",
      "vintage banned-to-restricted", "Channel",
      "vintage banned-to-restricted", "Mind Twist",
      "vintage+ restricted", "Demonic Consultation",
      "vintage+ restricted", "Necropotence"
  end


  def test_banlist_1999
    assert_banlist_changes "mar 1999",
      "standard banned", "Dream Halls",
      "standard banned", "Earthcraft",
      "standard banned", "Fluctuator",
      "standard banned", "Lotus Petal",
      "standard banned", "Recurring Nightmare",
      "standard banned", "Time Spiral",
      "standard banned", "Memory Jar", # banned retroactively in mid in mid March.
      "extended banned", "Memory Jar", # banned retroactively in mid in mid March.
      "urza block banned", "Time Spiral",
      "urza block banned", "Memory Jar",
      "urza block banned", "Windfall",
      # This is literally impossible according to "legacy and vintage unlinked sep 2004" theory
      # but that's what http://members.tripod.com/blue_midget/Gossip/banned.htm says
      # "legacy unbanned", "Candelabra of Tawnos",
      # "legacy unbanned", "Copy Artifact",
      # "legacy unbanned", "Maze of Ith",
      # "legacy unbanned", "Zuran Orb",
      # "legacy unbanned", "Mishra's Workshop",
      # "legacy banned", "Time Spiral",
      # "legacy banned", "Memory Jar",
      # "vintage+ unrestricted", "Maze of Ith",
      "vintage+ restricted", "Time Spiral"

    assert_banlist_changes "jun 1999",
      "standard banned", "Mind Over Matter",
      "extended banned", "Time Spiral",
      "urza block banned", "Gaea's Cradle",
      "urza block banned", "Serra's Sanctum",
      "urza block banned", "Tolarian Academy",
      "urza block banned", "Voltaic Key"

    assert_banlist_changes "jul 1999",
      "extended banned", "Yawgmoth's Bargain"

    assert_banlist_changes "sep 1999",
      "extended banned", "Dream Halls",
      "extended banned", "Earthcraft",
      "extended banned", "Lotus Petal",
      "extended banned", "Mind Over Matter",
      "extended banned", "Yawgmoth's Will",
      # "vintage+ unbanned", "Divine Intervention",
      "vintage+ unbanned", "Shahrazad",
      "vintage+ unrestricted", "Ivory Tower",
      # "vintage+ unrestricted", "Mirror Universe",
      # "vintage+ unrestricted", "Underworld Dreams",
      "vintage+ restricted", "Crop Rotation",
      "vintage+ restricted", "Doomsday",
      "vintage+ restricted", "Dream Halls",
      "vintage+ restricted", "Enlightened Tutor",
      "vintage+ restricted", "Frantic Search",
      "vintage+ restricted", "Grim Monolith",
      "vintage+ restricted", "Hurkyl's Recall",
      "vintage+ restricted", "Lotus Petal",
      "vintage+ restricted", "Mana Crypt",
      "vintage+ restricted", "Mana Vault",
      "vintage+ restricted", "Mind Over Matter",
      "vintage+ restricted", "Mox Diamond",
      "vintage+ restricted", "Mystical Tutor",
      "vintage+ restricted", "Tinker",
      "vintage+ restricted", "Vampiric Tutor",
      "vintage+ restricted", "Voltaic Key",
      "vintage+ restricted", "Yawgmoth's Bargain",
      "vintage+ restricted", "Yawgmoth's Will"
  end

  def test_banlist_1998
    assert_banlist_changes "December 1998",
      "standard banned", "Tolarian Academy",
      "standard banned", "Windfall",
      "extended banned", "Tolarian Academy",
      "extended banned", "Windfall",
      # "extended unbanned", "Braingeyser",
      # This is not supposed to happen:
      # "legacy unbanned", "Feldon's Cane",
      "vintage+ restricted", "Stroke of Genius",
      "vintage+ restricted", "Tolarian Academy",
      "vintage+ restricted", "Windfall"
  end

  def test_banlist_1997
    assert_banlist_changes "April 1997",
      "ice age block banned", "Thawing Glaciers",
      "ice age block banned", "Zuran Orb"

    assert_banlist_changes "June 1997",
      "standard banned", "Zuran Orb",
      "vintage+ restricted", "Black Vise",
      "mirage block banned", "Squandered Resources"

    assert_banlist_changes "September 1997",
      "extended banned", "Hypnotic Specter",
      # "extended unbanned", "Juggernaut",
      "vintage+ unrestricted", "Candelabra of Tawnos",
      "vintage+ unrestricted", "Copy Artifact",
      "vintage+ unrestricted", "Feldon's Cane"
      # "vintage+ unrestricted", "Mishra's Workshop",
      # "vintage+ unrestricted", "Zuran Orb"
  end

  def test_banlist_1996
    assert_banlist_changes "January 1996",
      "standard banned", "Mind Twist",
      "standard restricted", "Black Vise",
      "vintage+ banned", "Mind Twist",
      "vintage+ restricted", "Black Vise"

    assert_banlist_changes "March 1996",
      # "standard unrestricted", "Feldon's Cane",
      # "standard unrestricted", "Maze of Ith",
      # "standard unrestricted", "Recall",
      "vintage+ unbanned", "Time Vault",
      "vintage+ unrestricted", "Ali from Cairo",
      # "vintage+ unrestricted", "Sword of the Ages",
      "vintage+ unrestricted", "Black Vise"

    assert_banlist_changes "June 1996",
      "standard restricted", "Land Tax"

    assert_banlist_changes "September 1996",
      "standard restricted", "Hymn to Tourach",
      "standard restricted", "Strip Mine",
      "vintage+ restricted", "Fastbond"

    # December 1996: Standard: All cards on the restricted list are moved to the banned list.
    # I added that to BanList, but reliability of data so old is so low that I'm not even going to test that
  end

  def test_banlist_1995
    assert_banlist_changes "April 1995",
      "vintage+ restricted", "Balance",
      "standard restricted", "Balance"
  end

  def test_banlist_1994
    assert_full_banlist "vintage", "January 1, 1994", [
      "Contract from Below",
      "Darkpact",
      "Demonic Attorney",
      "Jeweled Bird",
      "Bronze Tablet", # all ante cards are banned in advance
      "Amulet of Quoz",
      "Timmerian Fiends",
      "Tempest Efreet",
      "Rebirth",
      "Chaos Orb",
      "Falling Star",
      "Shahrazad",
    ] + [
      # conspiracy
      "Advantageous Proclamation",
      "Backup Plan",
      "Brago's Favor",
      "Double Stroke",
      "Immediate Action",
      "Iterative Analysis",
      "Muzzio's Preparations",
      "Power Play",
      "Secret Summoning",
      "Secrets of Paradise",
      "Sentinel Dispatch",
      "Unexpected Potential",
      "Worldknit",
    ], [
      "Ali from Cairo",
      "Ancestral Recall",
      "Berserk",
      "Black Lotus",
      "Braingeyser",
      "Dingus Egg",
      "Gauntlet of Might",
      "Icy Manipulator",
      "Mox Pearl",
      "Mox Emerald",
      "Mox Ruby",
      "Mox Sapphire",
      "Mox Jet",
      "Orcish Oriflamme",
      "Rukh Egg",
      "Sol Ring",
      "Timetwister",
      "Time Vault",
      "Time Walk",
    ]

    assert_banlist_changes "May 1994",
      "vintage+ restricted", "Candelabra of Tawnos",
      "vintage+ restricted", "Channel",
      "vintage+ restricted", "Copy Artifact",
      "vintage+ restricted", "Demonic Tutor",
      "vintage+ restricted", "Feldon's Cane",
      "vintage+ restricted", "Ivory Tower",
      "vintage+ restricted", "Library of Alexandria",
      "vintage+ restricted", "Regrowth",
      "vintage+ restricted", "Wheel of Fortune",
      "vintage+ restricted-to-banned", "Time Vault",
      "vintage+ unrestricted", "Dingus Egg",
      "vintage+ unrestricted", "Gauntlet of Might",
      "vintage+ unrestricted", "Icy Manipulator",
      "vintage+ unrestricted", "Orcish Oriflamme",
      "vintage+ unrestricted", "Rukh Egg"
  end

  def test_banlist_1993
    # Everything was legal back then
  end

  ##################################################

  def test_legacy_vintage_split
    assert_full_banlist "legacy", "September 20, 2004", [
      "Amulet of Quoz",
      "Ancestral Recall",
      "Balance",
      "Bazaar of Baghdad",
      "Black Lotus",
      "Black Vise",
      "Bronze Tablet",
      "Channel",
      "Chaos Orb",
      "Contract from Below",
      "Darkpact",
      "Demonic Attorney",
      "Demonic Consultation",
      "Demonic Tutor",
      "Dream Halls",
      "Earthcraft",
      "Entomb",
      "Falling Star",
      "Fastbond",
      "Frantic Search",
      "Goblin Recruiter",
      "Grim Monolith",
      "Gush",
      "Hermit Druid",
      "Illusionary Mask",
      "Jeweled Bird",
      "Land Tax",
      "Library of Alexandria",
      "Mana Crypt",
      "Mana Drain",
      "Mana Vault",
      "Memory Jar",
      "Metalworker",
      "Mind Over Matter",
      "Mind Twist",
      "Mind's Desire",
      "Mishra's Workshop",
      "Mox Emerald",
      "Mox Jet",
      "Mox Pearl",
      "Mox Ruby",
      "Mox Sapphire",
      "Necropotence",
      "Oath of Druids",
      "Rebirth",
      "Replenish",
      "Skullclamp",
      "Sol Ring",
      "Strip Mine",
      "Tempest Efreet",
      "Time Spiral",
      "Time Walk",
      "Timetwister",
      "Timmerian Fiends",
      "Tinker",
      "Tolarian Academy",
      "Vampiric Tutor",
      "Wheel of Fortune",
      "Windfall",
      "Worldgorger Dragon",
      "Yawgmoth's Bargain",
      "Yawgmoth's Will",
    ] + [
    # conspiracy cards
      "Advantageous Proclamation",
      "Backup Plan",
      "Brago's Favor",
      "Double Stroke",
      "Immediate Action",
      "Iterative Analysis",
      "Muzzio's Preparations",
      "Power Play",
      "Secret Summoning",
      "Secrets of Paradise",
      "Sentinel Dispatch",
      "Unexpected Potential",
      "Worldknit",
    ]
  end

  def test_legacy_was_just_vintage_plus_before_split
    cutoff_date = @ban_list.dates["sep 2004"]
    change_dates = @ban_list.dates.values.uniq.sort
    change_dates.each do |date|
      legacy_banlist  = @ban_list.full_ban_list("legacy", date)
      vintage_banlist = @ban_list.full_ban_list("vintage", date)
      vintage_plus_banlist = Hash[vintage_banlist.map{|k,v| [k, v == "restricted" ? "banned" : v]}]
      if date < cutoff_date
        assert_hash_equal legacy_banlist, vintage_plus_banlist, "Legacy is Vintage+ at #{date}"
      else
        refute_equal legacy_banlist, vintage_plus_banlist, "Legacy is not Vintage+ at #{date}"
      end
    end
  end

  def test_legends_restricted
    # assert false, "summon legend restricted until 1995"
  end

  def test_format_legality_changes
    # Starter Level sets Starter 1999, Starter 2000, Portal, Portal Second Age, and Portal Three Kingdoms become legal in Legacy and Vintage in October.
    # assert false, "This should go to another test"
    # Also all Exended variants etc. None of that belongs here
  end

  ##################################################
  # Formats in mtgjson are verified by indexer
  # Formats not in mtgjson should all be listed here

  def test_pauper_banlist_now
    assert_full_banlist "pauper", "1 October 2015", [
      "Cranial Plating",
      "Frantic Search",
      "Empty the Warrens",
      "Grapeshot",
      "Invigorate",
      "Cloudpost",
      "Temporal Fissure",
      "Treasure Cruise",
    ]
  end

  def test_two_headed_giant_banlist_now
    assert_full_banlist "two-headed giant", "1 October 2015", [
      "Erayo, Soratami Ascendant",
    ]
  end
end
