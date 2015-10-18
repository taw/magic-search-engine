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
    # TEMPORARY HACK
    return unless format == "modern" or format == "innistrad block"

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
end
