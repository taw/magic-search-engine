describe CardSheet do
  include_context "db"

  let(:m10) { db.sets["m10"] }
  %W[basic common uncommon rare mythic].each do |rarity|
    it "rarity #{rarity}" do
      expected = db.search("e:m10 r:#{rarity}").printings
      actual = CardSheet.rarity(m10, rarity).elements.map(&:main_front)
      expected.should match_array(actual)
    end

    it "cards" do
      sheet = CardSheet.rare_or_mythic(m10)
      sheet.number_of_cards.should eq(15+53)
      expected = db.search("e:m10 r>=rare").printings
      actual = sheet.cards.map(&:main_front)
      expected.should match_array(actual)
    end
  end

  # This even goes to Pack for extra routing test
  context "Masterpieces" do
    let(:pack) { Pack.for(db, set_code) }
    let(:masterpieces) { pack.masterpieces.elements.map(&:main_front) }
    let(:expected_masterpieces) do
      db.sets[masterpieces_set_code]
        .printings
        .select{|c| masterpieces_range === c.number.to_i }
    end

    context "bfz" do
      let(:set_code) { "bfz" }
      let(:masterpieces_set_code) { "exp" }
      let(:masterpieces_range) { 1..25 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "ogw" do
      let(:set_code) { "ogw" }
      let(:masterpieces_set_code) { "exp" }
      let(:masterpieces_range) { 26..45 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "kld" do
      let(:set_code) { "kld" }
      let(:masterpieces_set_code) { "mps" }
      let(:masterpieces_range) { 1..30 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "aer" do
      let(:set_code) { "aer" }
      let(:masterpieces_set_code) { "mps" }
      let(:masterpieces_range) { 31..54 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "akh" do
      let(:set_code) { "akh" }
      let(:masterpieces_set_code) { "mps_akh" }
      let(:masterpieces_range) { 1..30 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "hou" do
      let(:set_code) { "hou" }
      let(:masterpieces_set_code) { "mps_akh" }
      let(:masterpieces_range) { 31..54 }
      it { masterpieces.should eq(expected_masterpieces) }
    end
  end
end
