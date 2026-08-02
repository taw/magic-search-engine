describe LimitedFormat do
  include_context "db"

  let(:nph_draft) { db.sets["nph"].limited_formats.find{|f| f.type == "draft"} }
  let(:nph_prerelease) { db.sets["nph"].limited_formats.find{|f| f.type == "prerelease-sealed"} }
  let(:rtr_prerelease) { db.sets["rtr"].limited_formats.find{|f| f.type == "prerelease-sealed"} }

  it "draft boosters are in the order they are opened" do
    nph_draft.booster_order.map(&:code).should eq(["nph-draft", "mbs-draft", "som-draft"])
    nph_draft.play_variant.should eq(nil)
    db.sets["cmr"].limited_formats.find{|f| f.type == "draft"}.play_variant.should eq("commander")
  end

  it "promo cards" do
    nph_prerelease.playable_promo_cards.should eq([])
    nph_prerelease.unplayable_promo_cards.should eq([
      PhysicalCard.for(db.sets["pnph"].printing_by_number["73★"], true),
    ])
    promo = nph_prerelease.unplayable_promo_cards[0]
    promo.name.should eq("Sheoldred, Whispering One")
    promo.foil.should eq(true)
  end

  it "promo cards of every pool of a format with variants" do
    rtr_prerelease.pools.size.should eq(5)
    rtr_prerelease.playable_promo_cards.map(&:name).should match_array([
      "Archon of the Triumvirate",
      "Hypersonic Dragon",
      "Carnival Hellsteed",
      "Corpsejack Menace",
      "Grove of the Guardian",
    ])
  end

  # Promos that aren't in the card db are dropped with a warning, so count them
  it "every promo card exists" do
    db.limited_formats.each do |limited_format|
      listed = limited_format.pools.sum{|pool|
        (pool["playable_promo_cards"] || []).size + (pool["unplayable_promo_cards"] || []).size
      }
      limited_format.promo_cards.size.should eq(listed), "#{limited_format.inspect} has promo cards not in the card db"
    end
  end

  # Warning only, as the card db is regenerated from mtgjson and its foiling
  # information changes without us doing anything.
  # The other source is https://mtg.wiki/page/Prerelease_card
  it "foil tags agree with the card db" do
    db.limited_formats.each do |limited_format|
      limited_format.promo_cards.each do |promo|
        foiling = promo.main_front.foiling
        next if foiling == (promo.foil ? :foilonly : :nonfoil)
        warn "#{limited_format.inspect} promo #{promo.inspect} disagrees with the card db, which says foiling=#{foiling}"
      end
    end
  end
end
