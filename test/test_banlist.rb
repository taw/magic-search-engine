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

  def assert_banlist_status(set, format, expected_legality, card_name)
    set_date = @db.sets[set].release_date
    card = @db.cards[card_name]
    actual_legality = @ban_list.legality(format, card_name, set_date) || "legal"
    assert_equal expected_legality, actual_legality, "Legality of #{card_name} in #{format} during #{set}"
  end

  def assert_banlist_change(prev_set, this_set, format, change, card)
    case change
    when "banned"
      assert_banlist_status(prev_set, format, "legal", card)
      assert_banlist_status(this_set, format, "banned", card)
    when "unbanned"
      assert_banlist_status(prev_set, format, "banned", card)
      assert_banlist_status(this_set, format, "legal", card)
    when "restricted"
      assert_banlist_status(prev_set, format, "legal", card)
      assert_banlist_status(this_set, format, "restricted", card)
    when "unrestricted"
      assert_banlist_status(prev_set, format, "restricted", card)
      assert_banlist_status(this_set, format, "legal", card)
    else
      raise
    end
  end

  def assert_banlist_changes(date, *changes)
    prev_set, this_set = find_set_change_at_date(date)
    changes.each_slice(2) do |change, card|
      raise unless change =~ /\A(.*) (\S+)\z/
      assert_banlist_change prev_set, this_set, $1, $2, card
    end
  end

  # FIXME: This test only goes one way, it should check both ways
  def assert_full_banlist(format, time, *cards)
    time = Date.parse(time)
    cards.each do |card_name|
      actual_legality = @ban_list.legality(format, card_name, time) || "legal"
      assert_equal "banned", actual_legality, "#{card_name} should be banned in #{format} at #{time}"
    end
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
      "standard banned", "Jace, the Mind Sculptop",
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
    assert_full_banlist "modern", "August 2011",
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
      "Vault of Whispers"
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
      "mirrodin block banned", "AEther Vial",
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

    # Starter Level sets Starter 1999, Starter 2000, Portal, Portal Second Age, and Portal Three Kingdoms become legal in Legacy and Vintage in October.

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
      "vintage unrestricted", "Fork"

    # assert_banlist_changes "September 2004",
      # "Legacy becomes independent of Vintage"

    assert_banlist_status "December 2004",
      "vintage unrestricted", "Stroke of Genius"
  end

  def test_banlist_2003
    assert_banlist_changes "March 2003",
      "vintage unrestricted", "Berserk",
      "vintage unrestricted", "Hurkyl's Recall",
      "vintage unrestricted", "Recall" ,
      "vintage restricted", "Earthcraft",
      "vintage restricted", "Entomb",
      "legacy unbanned", "Berserk",
      "legacy unbanned", "Hurkyl's Recall",
      "legacy unbanned", "Recall",
      "legacy banned", "Earthcraft",
      "legacy banned", "Entomb"

    assert_banlist_changes "June 2003",
      "vintage restricted", "Gush",
      "vintage restricted", "Mind's Desire",
      "legacy banned", "Gush",
      "legacy banned", "Mind's Desire"

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
      "vintage restricted", "Burning Wish",
      "vintage restricted", "Chrome Mox",
      "vintage restricted", "Lion's Eye Diamond",
      "legacy banned", "Burning Wish",
      "legacy banned", "Chrome Mox",
      "legacy banned", "Lion's Eye Diamond"
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
      "vintage restricted", "Fact or Fiction",
      "legacy banned", "Fact or Fiction"
  end

  def test_banlist_2000
    assert_banlist_changes "March 2000",
      "extended banned", "Dark Ritual",
      "extended banned", "Mana Vault"

    assert_banlist_changes "June 2000",
      "masques block banned", "Lin Sivvi, Defiant Hero",
      "masques block banned", "Rishadan Port"

    assert_banlist_changes "September 2000",
      "vintage banned-to-restricte", "Channel",
      "vintage banned-to-restricte", "Mind Twist",
      "vintage restricted", "Demonic Consultation",
      "vintage restricted", "Necropotence",
      "legacy banned", "Demonic Consultation",
      "legacy banned", "Necropotence"
  end

  # Formats in mtgjson are verified by indexer
  # Formats not in mtgjson should all be listed here

  def test_pauper_banlist_now
    assert_full_banlist "pauper", "1 October 2015",
      "Cranial Plating",
      "Frantic Search",
      "Empty the Warrens",
      "Grapeshot",
      "Invigorate",
      "Cloudpost",
      "Temporal Fissure",
      "Treasure Cruise"
  end

  def test_two_headed_giant_banlist_now
    assert_full_banlist "two-headed giant", "1 October 2015",
      "Erayo, Soratami Ascendant"
  end
end
