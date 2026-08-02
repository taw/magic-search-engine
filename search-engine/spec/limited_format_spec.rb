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

  it "sealed pool boosters are listed with counts" do
    nph_prerelease.boosters.map{|count, pack| [count, pack.code]}.should eq([
      [2, "nph-draft"],
      [2, "mbs-draft"],
      [2, "som-draft"],
    ])
    nph_prerelease.simple_sealed?.should eq(true)
    nph_draft.simple_sealed?.should eq(false)
  end

  # Formats with a choice, random packs, or an unusual way of playing them
  it "formats with extra complexity are not simple sealed" do
    rtr_prerelease.choice.should eq("guild")
    rtr_prerelease.boosters.should eq([])
    rtr_prerelease.simple_sealed?.should eq(false)

    dgm_prerelease = db.sets["dgm"].limited_formats.find{|f| f.type == "prerelease-sealed"}
    dgm_prerelease.random_boosters.should_not eq([])
    dgm_prerelease.simple_sealed?.should eq(false)

    bbd_sealed = db.sets["bbd"].limited_formats.find{|f| f.type == "sealed"}
    bbd_sealed.pools.size.should eq(1)
    bbd_sealed.play_variant.should eq("two-headed-giant")
    bbd_sealed.simple_sealed?.should eq(false)
  end

  # Every booster of every simple sealed format has to be one we can open,
  # as those pages link into the sealed simulator
  it "simple sealed formats only use known boosters" do
    db.limited_formats.select(&:simple_sealed?).each do |limited_format|
      listed = limited_format.pools[0]["boosters"].size
      limited_format.boosters.size.should eq(listed), "#{limited_format.inspect} uses boosters we don't know"
    end
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
