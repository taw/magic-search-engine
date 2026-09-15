describe "Formats - Timeless" do
  include_context "db"

  let(:today) { Date.today }

  it "has no banned cards, and never had any" do
    assert_search_results "banned:timeless"
    Format["timeless"].new.ban_events.each do |_date, _url, _comment, events|
      events.map{|event| event[:new]}.should_not include("banned")
    end
  end

  # restricted:timeless would also return the conjurable/specialized cards,
  # which share the restricted status but aren't a ban list decision
  it "restricted list" do
    format = Format["timeless"].new
    restricted = db.cards.each_value.select{|card| format.legality(card) == "restricted" }
    restricted.map(&:name).sort.should eq(
      ["Channel", "Demonic Tutor", "Necropotence", "Tibalt's Trickery"]
    )
    assert_legality "timeless", Date.parse("2026-01-01"), "Necropotence", "legal"
    assert_legality "timeless", Date.parse("2026-03-01"), "Necropotence", "restricted"
  end

  # This is what the format was created for - the cards Historic pre-banned
  # instead of letting Arena have an eternal format
  it "cards pre-banned in Historic are legal" do
    assert_legality "timeless", today, "Flooded Strand", "legal"
    assert_legality "timeless", today, "Ragavan, Nimble Pilferer", "legal"
    assert_legality "timeless", today, "Force of Will", "legal"
    assert_legality "timeless", today, "Lightning Bolt", "legal"
  end

  # Timeless always played the original version of a rebalanced paper card where
  # Historic played the A- one. Arena reverted all of those on 2026-09-22, so the
  # card pools are now identical and only the ban lists tell the formats apart.
  it "has the same card pool as Historic" do
    assert_search_equal "f:timeless or banned:timeless", "f:historic or banned:historic"
    assert_legality "timeless", today, "Alrund, God of the Cosmos", "legal"
  end

  # Not a ban list decision - these can only be created during a game
  it "conjurable and specialized cards cannot be put in a deck" do
    assert_legality "timeless", today, "Black Lotus", "conjurable"
    assert_legality "timeless", today, "Tropical Island", "conjurable"
    assert_legality "timeless", today, "Alora, Cheerful Assassin", "specialized"
  end

  it "does not include cards which never came to Arena" do
    assert_search_results "f:timeless -in:arena"
    assert_legality "timeless", today, "Chaos Orb", nil
    assert_legality "timeless", today, "Sol Ring", nil
  end
end
