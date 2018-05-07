# TODO: WORK IN PROGRESS
describe Pack do
  include_context "db"

  it "Only sets of appropriate types have sealed packs" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      # Indexer responsibility to set this flag
      if set.has_boosters?
        pack = Pack.for(db, set_code)
        if pack
          pack.should be_a(Pack), "#{set_pp} should have packs"
        else
          # TODO: pending
        end
      else
        pack.should eq(nil), "#{set_pp} should not have packs"
      end
    end
  end

  # There's no way this is accurate, we're just approximating foils
  it "Every set with foils has all appropriate categories" do
    db.sets.each do |set_code, set|
      pack = Pack.for(db, set_code)
      next unless pack
      next unless pack.has_random_foil or pack.has_guaranteed_foil
      pack.pool(:rare_or_mythic).should_not be_empty
      pack.pool(:uncommon).should_not be_empty
      pack.pool(:common).should_not be_empty
      pack.pool(:basic_fallover_to_common).should_not be_empty
    end
  end

  context "flip cards" do
    it "Champions of Kamigawa" do
      pack = Pack.for(db, "chk")
      pack.cards_in_nonfoil_pools.size.should eq(88+89+110+20)
      pack.pool_size(:rare_or_mythic).should eq(88)
      # Brothers Yamazaki alt art
      pack.pool_size(:uncommon).should eq(88+1)
      pack.pool_size(:common).should eq(110)
      pack.pool_size(:basic).should eq(20)
    end

    it "Betrayers of Kamigawa" do
      pack = Pack.for(db, "bok")
      pack.cards_in_nonfoil_pools.size.should eq(55+55+55)
      pack.pool_size(:rare_or_mythic).should eq(55)
      pack.pool_size(:uncommon).should eq(55)
      pack.pool_size(:common).should eq(55)
    end

    it "Saviors of Kamigawa" do
      pack = Pack.for(db, "sok")
      pack.cards_in_nonfoil_pools.size.should eq(55+55+55)
      pack.pool_size(:rare_or_mythic).should eq(55)
      pack.pool_size(:uncommon).should eq(55)
      pack.pool_size(:common).should eq(55)
    end
  end

  context "physical cards are properly setup" do
    it "Dissention" do
      pack = Pack.for(db, "di")
      pack.cards_in_nonfoil_pools.size.should eq(60+60+60)
      # 5 rares are split
      pack.pool_size(:rare_or_mythic).should eq(60)
      # 5 rares are split
      pack.pool_size(:uncommon).should eq(60)
      pack.pool_size(:common).should eq(60)
      # split cards setup correctly
      pack.cards_in_nonfoil_pools.map(&:name).should include("Trial // Error")
    end
  end

  # TODO: dfc / aftermath / meld cards

  context "Masterpieces" do
    let(:pack) { Pack.for(db, set_code) }
    let(:masterpieces) { pack.masterpieces }
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

  context "Planeswalker decks card are not in boosters" do
    # TODO: tests
  end

  it "Every card can appear in a pack" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = Pack.for(db, set_code)
      next unless pack
      pack.cards_in_nonfoil_pools.should match_array(pack.physical_cards_in_boosters),
        "All cards in #{set_pp} should be possible in its packs as nonfoil"
    end
  end
end
