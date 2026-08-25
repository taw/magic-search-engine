describe "Foil queries" do
  include_context "db"
  let(:nonfoil) { db.printings.select{|c| c.nonfoilonly? } }
  let(:foilonly) { db.printings.select{|c| c.foilonly? } }
  let(:both) { db.printings.select{|c| c.foilboth? } }

  # These are just boring unit tests
  it "is:foil" do
    db.search("is:foil").printings.should match_array(foilonly + both)
  end

  it "is:nonfoil" do
    db.search("is:nonfoil").printings.should match_array(nonfoil + both)
  end

  # Etched is a kind of foiling, so every query which asks about foil takes it
  # - `is:productlessetched` and `is:productlessfoil` are the only two that
  # tell the two premium finishes apart
  it "etched cards are foil" do
    "is:etched -is:foil".should return_no_cards
    "is:etched is:nonfoilonly".should return_no_cards
  end

  # A printing comes in at least one finish, so it is in exactly one of these
  it "every printing is foil only, nonfoil only, or both" do
    (foilonly.size + nonfoil.size + both.size).should eq(db.printings.size)
    db.search("is:foilboth").printings.should match_array(both)
    db.search("is:foilonly").printings.should match_array(foilonly)
    db.search("is:nonfoilonly").printings.should match_array(nonfoil)
  end
end
