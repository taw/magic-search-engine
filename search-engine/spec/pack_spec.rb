describe Pack do
  include_context "db"

  it "Only sets of appropriate types have sealed packs" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      case set.type
      when "expansion", "core", "un"
        Pack.for(db, set_code).should be_a(Pack), "#{set_pp} should have packs"
      when "duel deck", "board game deck", "from the vault", "promo", "commander",
        "archenemy", "planechase", "premium deck", "masterpiece", "masters", "conspiracy"
        # Masterpieces are included in another set's packs
        Pack.for(db, set_code).should eq(nil), "#{set_pp} should not have packs"
      else
        # "#{set_code} / #{set.type}".should eq("who knows")
      end
    end
  end
end
