# TODO: WORK IN PROGRESS
describe Pack do
  include_context "db"

  it "Only sets of appropriate types have sealed packs" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = Pack.for(db, set_code)
      type = set.type
      type = "collector edition" if ["ced", "cedi"].include?(set_code)
      type = "tsts" if set_code == "tsts"
      case type
      when "expansion", "core", "un", "reprint"
        if pack
          pack.should be_a(Pack), "#{set_pp} should have packs"
        else
          # TODO: pending
        end
      when "duel deck", "board game deck", "from the vault", "promo", "commander",
        "archenemy", "planechase", "premium deck", "masterpiece", "masters", "conspiracy",
        "box", "vanguard", "starter", "collector edition", "tsts"
        # Masterpieces and tsts are included in another set's packs
        pack.should eq(nil), "#{set_pp} should not have packs"
      else
        raise "Not sure if #{set_pp} should have packs or not"
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

  context "split cards only appear as left side" do
    it "Dissention" do
      pack = Pack.for(db, "di")
      pack.cards_in_nonfoil_pools.size.should eq(60+60+60)
      # 5 rares are split
      pack.pool_size(:rare_or_mythic).should eq(60)
      # 5 rares are split
      pack.pool_size(:uncommon).should eq(60)
      pack.pool_size(:common).should eq(60)
      # Only A side
      pack.cards_in_nonfoil_pools.count{|c| c.number =~ /a/}.should eq(10)
      pack.cards_in_nonfoil_pools.count{|c| c.number =~ /b/}.should eq(0)
    end
  end

  # TODO: dfc / aftermath / meld cards

  it "Every card can appear in a pack" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = Pack.for(db, set_code)
      next unless pack
      pack.cards_in_nonfoil_pools.should match_array(pack.physical_cards),
        "All cards in #{set_pp} should be possible in its packs as nonfoil"
    end
  end
end
