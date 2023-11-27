describe "Foil queries" do
  include_context "db"
  let(:nonfoil) { db.printings.select{|c| c.foiling == :nonfoil } }
  let(:foilonly) { db.printings.select{|c| c.foiling == :foilonly } }
  let(:both) { db.printings.select{|c| c.foiling == :both } }

  # These are just boring unit tests
  it "is:foil" do
    db.search("is:foil").printings.should match_array(foilonly + both)
  end

  it "is:nonfoil" do
    db.search("is:nonfoil").printings.should match_array(nonfoil + both)
  end
end
