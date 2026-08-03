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
    nph_prerelease.pools.size.should eq(1)
    nph_prerelease.pools[0].name.should eq(nil)
    nph_prerelease.pools[0].boosters.map{|count, pack| [count, pack.code]}.should eq([
      [2, "nph-draft"],
      [2, "mbs-draft"],
      [2, "som-draft"],
    ])
    nph_prerelease.describable_sealed?.should eq(true)
    nph_draft.describable_sealed?.should eq(false)
  end

  it "one pool per choice, with its own packs and promos" do
    rtr_prerelease.choice.should eq("guild")
    rtr_prerelease.describable_sealed?.should eq(true)
    rtr_prerelease.pools.map(&:slug).should eq(["azorius", "izzet", "rakdos", "golgari", "selesnya"])
    rtr_prerelease.pools.map(&:name).should eq(["Azorius", "Izzet", "Rakdos", "Golgari", "Selesnya"])

    azorius = rtr_prerelease.pools[0]
    azorius.boosters.map{|count, pack| [count, pack.code]}.should eq([
      [5, "rtr-draft"],
      [1, "rtr-prerelease-azorius"],
    ])
    azorius.playable_promo_cards.map(&:name).should eq(["Archon of the Triumvirate"])
    azorius.unplayable_promo_cards.should eq([])
  end

  # Formats with random packs
  it "formats with extra complexity are not describable sealed" do
    dgm_prerelease = db.sets["dgm"].limited_formats.find{|f| f.type == "prerelease-sealed"}
    dgm_prerelease.random_boosters.should_not eq([])
    dgm_prerelease.describable_sealed?.should eq(false)
  end

  # Sets played as something else than normal limited have their own rules text
  it "formats with a play variant are describable" do
    bbd_sealed = db.sets["bbd"].limited_formats.find{|f| f.type == "sealed"}
    bbd_sealed.pools.size.should eq(1)
    bbd_sealed.play_variant.should eq("two-headed-giant")
    bbd_sealed.describable_sealed?.should eq(true)

    cmr_draft = db.sets["cmr"].limited_formats.find{|f| f.type == "draft"}
    cmr_draft.describable_draft?.should eq(true)
    cmr_draft.describable_sealed?.should eq(false)
    nph_draft.describable_draft?.should eq(true)
    nph_prerelease.describable_draft?.should eq(false)
  end

  # Sets which were never printed on paper were only drafted on Magic Online
  it "mtgo drafts are ordinary drafts of a digital set" do
    vma_draft = db.sets["vma"].limited_formats.find{|f| f.type == "mtgo-draft"}
    vma_draft.format_type.should eq("draft")
    vma_draft.describable_draft?.should eq(true)
    vma_draft.mtgo?.should eq(true)
    vma_draft.booster_order.map(&:code).should eq(["vma-mtgo"] * 3)
    vma_draft.to_s.should eq("Vintage Masters MTGO Draft")
    vma_draft.slug.should eq("mtgo-draft")
    vma_draft.digital_client.should eq("Magic Online")
    nph_draft.mtgo?.should eq(false)
  end

  # Magic Arena has its own boosters, so an Arena draft of a paper set is a
  # different format from the paper draft of the same set
  it "arena drafts are ordinary drafts out of Arena's own boosters" do
    dom_arena_draft = db.sets["dom"].limited_formats.find{|f| f.type == "arena-draft"}
    dom_arena_draft.format_type.should eq("draft")
    dom_arena_draft.describable_draft?.should eq(true)
    dom_arena_draft.arena?.should eq(true)
    dom_arena_draft.mtgo?.should eq(false)
    dom_arena_draft.booster_order.map(&:code).should eq(["dom-arena"] * 3)
    dom_arena_draft.to_s.should eq("Dominaria Arena Draft")
    dom_arena_draft.slug.should eq("arena-draft")
    dom_arena_draft.digital_client.should eq("Magic Arena")
    nph_draft.arena?.should eq(false)
    nph_draft.digital_client.should eq(nil)
  end

  # Arena drafted Rivals of Ixalan the same way paper did, two packs of Rivals
  # and one of Ixalan, just out of Arena boosters
  it "arena drafts follow the block structure of the paper draft" do
    rix_arena_draft = db.sets["rix"].limited_formats.find{|f| f.type == "arena-draft"}
    rix_arena_draft.booster_order.map(&:code).should eq(["rix-arena", "rix-arena", "xln-arena"])
  end

  # Commander Draft lets you use a filler commander you did not draft (903.13e)
  it "filler commanders" do
    db.sets["cmr"].limited_formats.find{|f| f.type == "draft"}
      .filler_commanders.map(&:name).should eq(["The Prismatic Piper"])
    db.sets["clb"].limited_formats.find{|f| f.type == "prerelease-sealed"}
      .filler_commanders.map(&:name).should eq(["Faceless One"])
    nph_draft.filler_commanders.should eq([])
  end

  # Every booster of every described pool has to be one we can open,
  # as those pages link into the sealed simulator
  it "described sealed formats only use known boosters" do
    db.limited_formats.select(&:describable_sealed?).each do |limited_format|
      limited_format.pools.each do |pool|
        pool.boosters.size.should eq(pool.data["boosters"].size), "#{pool.inspect} uses boosters we don't know"
      end
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
        (pool.data["playable_promo_cards"] || []).size + (pool.data["unplayable_promo_cards"] || []).size
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
