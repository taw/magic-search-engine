describe "is:tournament" do
  include_context "db"

  # Everything that can't be brought to a sanctioned event implies not:tournament.
  it "covers non-traditional printings" do
    assert_search_results "not:traditional is:tournament"
  end

  # CR 100.7's cards intended for casual play
  it "covers playtest cards, silver borders and acorn stamps" do
    assert_search_results "promo:playtest is:tournament"
    assert_search_results "border:silver is:tournament"
    assert_search_results "stamp:acorn is:tournament"
    assert_search_results "stamp:heart is:tournament"
  end

  # is:funny is a card-level flag and this is a printing-level one, so they can only
  # be compared this way round. The exceptions are the acorn Alchemy conversions, where
  # the acorn is on the paper printing and funny back-propagates to the Arena original -
  # the Arena printing really is an ordinary printing, so is:funny is what's wrong there.
  # Pinned so the list can't grow unnoticed.
  it "covers funny cards, except where is:funny itself is wrong" do
    assert_search_equal "is:funny is:tournament", "is:funny is:tournament game:arena"
    db.search("is:funny is:tournament").printings.size.should eq(16)
  end

  # Mixed products are why this is per-printing. Marking whole sets got these wrong.
  it "lets mixed products come out right" do
    # MB2's ordinary reprints are legal, its playtest cards are not
    assert_search_results "e:mb2 is:tournament !Goblin Gang Leader", "Goblin Gang Leader"
    assert_search_results "e:mb2 promo:playtest is:tournament"
    # the card Counterspell is legal, its playtest-framed printing is not
    assert_search_results "e:sld number=sctlr is:tournament"
    Format["vintage"].new.legality(db.cards["counterspell"]).should eq("legal")
  end

  # Formats are built on this now, not on card.funny
  it "is what format legality uses" do
    # Call from the Grave is an Astral card with an mb2 playtest reprint - neither
    # printing can make it legal, and neither is funny by set any more
    db.cards["call from the grave"].legality_information.to_h.should eq({})
    db.cards["call from the grave"].funny.should eq(false)
  end
end
