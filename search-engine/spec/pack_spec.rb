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
      case set.type
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
      next unless pack and pack.foil
      pack.pool(:rare_or_mythic).should_not be_empty
      pack.pool(:uncommon).should_not be_empty
      pack.pool(:common).should_not be_empty
      pack.pool(:basic_fallover_to_common).should_not be_empty
    end
  end

  # TODO: Flip cards

  # TODO: Split cards

  # TODO: dfc / aftermath / meld cards

  it "Every card can appear in a pack" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = Pack.for(db, set_code)
      next unless pack
      possible_nonfoil_cards_in_packs = pack.distribution.keys.flat_map{|k| pack.pool(k)}.uniq
      possible_nonfoil_cards_in_packs.should match_array(set.printings),
        "All cards in #{set_pp} should be possible in its packs as nonfoil"
    end
  end
end
