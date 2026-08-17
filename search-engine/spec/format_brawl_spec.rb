describe "Formats - Brawl" do
  include_context "db"

  let(:today) { Date.today }

  # Not the historical count - Historic Brawl launched with 11 bans in 2020 and has
  # gained and lost some since
  it "banned list" do
    assert_count_cards "banned:brawl", 35
    assert_legality "brawl", today, "Force of Will", "banned"
    assert_legality "brawl", today, "Fierce Guardianship", "banned"
    assert_legality "brawl", today, "Iona, Shield of Emeria", "banned"
  end

  it "unbanned cards are legal again" do
    assert_legality "brawl", Date.parse("2021-01-01"), "Golos, Tireless Pilgrim", "banned"
    assert_legality "brawl", today, "Golos, Tireless Pilgrim", "legal"
  end

  # has_alchemy is not time-aware: the original card drops out of the pool the moment a
  # rebalanced version exists, retroactively, so Teferi and Winota read as never having
  # been in Brawl even though they were banned in it at launch. Their ban list entries
  # are still here and still correct - it's in_format? that can't express it. Historic
  # has the same blind spot.
  it "loses history of cards that were later rebalanced" do
    assert_legality "brawl", Date.parse("2021-01-01"), "Teferi, Time Raveler", nil
    assert_legality "brawl", Date.parse("2021-01-01"), "Winota, Joiner of Forces", nil
  end

  # Brawl's whole point - it doesn't inherit Historic's pre-bans
  it "cards banned in Historic are legal here" do
    assert_legality "brawl", today, "Flooded Strand", "legal"
    assert_legality "brawl", today, "Ragavan, Nimble Pilferer", "legal"
    assert_legality "brawl", today, "Brainstorm", "legal"
  end

  # Same pool as Historic, rebalanced versions and all - unlike Timeless
  it "pool is Historic's" do
    assert_search_equal "f:brawl or banned:brawl", "f:historic or banned:historic"
    assert_search_results "f:brawl -in:arena"
    assert_legality "brawl", today, "Alrund, God of the Cosmos (Alchemy)", "legal"
    assert_legality "brawl", today, "Alrund, God of the Cosmos", nil
    assert_legality "brawl", today, "Chaos Orb", nil
  end

  it "conjurable and specialized cards cannot be put in a deck" do
    assert_legality "brawl", today, "Black Lotus", "conjurable"
    assert_legality "brawl", today, "Alora, Cheerful Assassin", "specialized"
    # Conjurable in Historic only because it's pre-banned there anyway
    assert_legality "brawl", today, "Lightning Bolt", "legal"
  end
end

describe "Formats - Competitive Brawl" do
  include_context "db"

  let(:today) { Date.today }

  it "banned list is ten commanders" do
    banned = db.cards.each_value.select{|card| Format["competitive brawl"].new.legality(card) == "banned" }
    banned.map(&:name).sort.should eq([
      "Ajani, Nacatl Pariah",
      "Lutri, the Spellchaser",
      "Nadu, Winged Wisdom (Alchemy)",
      "Oko, Thief of Crowns",
      "Old Stickfingers",
      "Ragavan, Nimble Pilferer",
      "Rusko, Clockmaker",
      "Tajic, Legion's Valor",
      "Tamiyo, Inquisitive Student",
      "Wrenn and Six",
    ])
    banned.each{|card| card.brawler?.should eq(true) } # they're all commander bans
  end

  # The two lists are built on opposite principles, neither is a subset of the other
  it "does not share Brawl's banned list" do
    assert_legality "competitive brawl", today, "Force of Will", "legal"
    assert_legality "competitive brawl", today, "Mana Drain", "legal"
    assert_legality "competitive brawl", today, "Nexus of Fate", "legal"
    assert_legality "brawl", today, "Ragavan, Nimble Pilferer", "legal"
    assert_legality "brawl", today, "Wrenn and Six", "legal"
  end

  it "pool is Brawl's" do
    assert_search_equal "f:\"competitive brawl\" or banned:\"competitive brawl\"", "f:brawl or banned:brawl"
  end
end
