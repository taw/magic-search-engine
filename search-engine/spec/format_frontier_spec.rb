describe "Formats - Frontier" do
  include_context "db"

  let(:regular_sets) { db.sets.values.select{|s|
    s.type == "core" or s.type == "expansion" or s.name =~ /Welcome Deck/
  }.to_set }

  describe "Frontier legal sets" do
    let(:start_date) { db.sets["m15"].release_date }
    let(:expected) { regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set }
    let(:actual) { FormatFrontier.new.included_sets }
    it { expected.should eq actual }
  end

  it "frontier" do
    assert_block_composition "frontier", "xln", ["m15", "ktk", "frf", "dtk", "ori", "bfz", "ogw", "soi", "w16", "emn", "kld", "aer", "akh", "w17", "hou", "xln"]
  end
end
