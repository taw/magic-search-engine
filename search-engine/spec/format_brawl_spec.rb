describe "Formats - Brawl" do
  include_context "db"

  let(:today) { Date.today }

  # Not the historical count - Historic Brawl launched with 11 bans in 2020 and has
  # gained and lost some since
  it "banned list" do
    assert_count_cards "banned:brawl", 37
    assert_legality "brawl", today, "Force of Will", "banned"
    assert_legality "brawl", today, "Fierce Guardianship", "banned"
    assert_legality "brawl", today, "Iona, Shield of Emeria", "banned"
  end

  it "unbanned cards are legal again" do
    assert_legality "brawl", Date.parse("2021-01-01"), "Golos, Tireless Pilgrim", "banned"
    assert_legality "brawl", today, "Golos, Tireless Pilgrim", "legal"
  end

  # These two used to read as never having been in Brawl - a rebalanced version took
  # the original card's place in the pool retroactively, and that was not time-aware.
  # Arena reverted every rebalanced card on 2026-09-22, so their launch bans are
  # visible again.
  it "keeps history of cards that were rebalanced in between" do
    assert_legality "brawl", Date.parse("2021-01-01"), "Teferi, Time Raveler", "banned"
    assert_legality "brawl", Date.parse("2021-01-01"), "Winota, Joiner of Forces", "banned"
  end

  # Brawl's whole point - it doesn't inherit Historic's pre-bans
  it "cards banned in Historic are legal here" do
    assert_legality "brawl", today, "Flooded Strand", "legal"
    assert_legality "brawl", today, "Ragavan, Nimble Pilferer", "legal"
    assert_legality "brawl", today, "Brainstorm", "legal"
  end

  # Same pool as Historic, and since the rebalanced cards went away, as Timeless too
  it "pool is Historic's" do
    assert_search_equal "f:brawl or banned:brawl", "f:historic or banned:historic"
    assert_search_results "f:brawl -in:arena"
    assert_legality "brawl", today, "Alrund, God of the Cosmos", "legal"
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
      "Nadu, Winged Wisdom",
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
