describe "Legality information" do
  include_context "db"

  def legality_information(name, date = nil)
    db.cards[name.downcase].legality_information(date)
  end

  # BanList says which statuses exist, Format says which of them count as restricted.
  # They're separate lists in separate files, so make sure they stay in sync.
  it "every legality status is accounted for" do
    (Format::RESTRICTED_STATUSES.to_a - BanList::LEGALITY_STATUSES).should eq([])
    (BanList::LEGALITY_STATUSES - ["legal", "banned"] - Format::RESTRICTED_STATUSES.to_a).should eq([])
    Format::LEGAL_OR_RESTRICTED_STATUSES.to_a.should match_array(["legal", *Format::RESTRICTED_STATUSES])
  end

  it "legal everywhere" do
    legality_information("Island").should be_legal_everywhere
    legality_information("Giant Spider").should_not be_legal_everywhere
    legality_information("Birthing Pod").should_not be_legal_everywhere
    legality_information("Naya").should_not be_legal_everywhere
    legality_information("Backup Plan").should_not be_legal_everywhere
    legality_information("Amulet of Quoz").should_not be_legal_everywhere
  end

  it "legal nowhere" do
    legality_information("Island").should_not be_legal_nowhere
    legality_information("Giant Spider").should_not be_legal_nowhere
    legality_information("Birthing Pod").should_not be_legal_nowhere
    legality_information("Naya").should be_legal_nowhere # all "not in format"
    legality_information("Backup Plan").should be_legal_nowhere # all "not in format"
    legality_information("Amulet of Quoz").should be_legal_nowhere # mix of "banned" and "not in format"
  end
end
