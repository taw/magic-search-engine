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

  # Formats with random packs - the Dragon's Maze prerelease handed out a
  # booster of one guild allied with the one you picked, chosen at random
  it "formats with random packs are describable sealed" do
    dgm_prerelease = db.sets["dgm"].limited_formats.find{|f| f.type == "prerelease-sealed"}
    dgm_prerelease.describable_sealed?.should eq(true)

    azorius = dgm_prerelease.pools[0]
    azorius.name.should eq("Azorius")
    azorius.boosters.map{|count, pack| [count, pack.code]}.should eq([
      [4, "dgm-draft"],
      [1, "rtr-prerelease-azorius"],
    ])
    azorius.random_boosters.size.should eq(1)
    allied = azorius.random_boosters[0]
    allied.pick.should eq(1)
    allied.name.should eq("allied guild booster")
    allied.packs.map(&:code).should eq([
      "gtc-prerelease-orzhov",
      "gtc-prerelease-dimir",
      "gtc-prerelease-boros",
      "gtc-prerelease-simic",
    ])
    allied.describable?.should eq(true)
    azorius.unplayable_promo_cards.map(&:name).should eq(["Maze's End", "Plains"])
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

  # Jumpstart is two half decks shuffled together, so it is a sealed pool of
  # two packs whose play variant comes with the format rather than with the set
  it "jumpstart is a sealed pool of two half decks" do
    dmu_jumpstart = db.sets["dmu"].limited_formats.find{|f| f.type == "jumpstart"}
    dmu_jumpstart.format_type.should eq("sealed")
    dmu_jumpstart.play_variant.should eq("jumpstart")
    dmu_jumpstart.describable_sealed?.should eq(true)
    dmu_jumpstart.pools[0].boosters.map{|count, pack| [count, pack.code]}.should eq([
      [2, "dmu-jumpstart"],
    ])
    dmu_jumpstart.to_s.should eq("Dominaria United Jumpstart")
    # The set's other formats are played normally, so the variant is not set wide
    db.sets["dmu"].limited_formats.find{|f| f.type == "draft"}.play_variant.should eq(nil)
    # A set whose name already says Jumpstart names the format itself
    db.sets["jmp"].limited_formats.map(&:to_s).should eq(["Jumpstart"])
    db.sets["j25"].limited_formats.map(&:to_s).should eq(["Foundations Jumpstart"])
  end

  # The Lord of the Rings printed two volumes of Jumpstart packs, and a game is
  # any two of them, so the pool is all random packs and nothing fixed
  it "jumpstart of a set with two volumes of packs picks any two" do
    ltr_jumpstart = db.sets["ltr"].limited_formats.find{|f| f.type == "jumpstart"}
    ltr_jumpstart.describable_sealed?.should eq(true)
    pool = ltr_jumpstart.pools[0]
    pool.boosters.should eq([])
    pool.random_boosters.size.should eq(1)
    pool.random_boosters[0].pick.should eq(2)
    pool.random_boosters[0].packs.map(&:code).should eq(["ltr-jumpstart", "ltr-jumpstart-v2"])
    pool.describable?.should eq(true)
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

  # A set whose Arena boosters changed as its bonus sheet rotated was drafted
  # once per booster, and each of those runs is a format of its own
  it "sets with rotating arena boosters have one draft per booster" do
    sir_drafts = db.sets["sir"].limited_formats.select(&:arena?)
    sir_drafts.map(&:type).should eq(["arena-draft-1", "arena-draft-2", "arena-draft-3", "arena-draft-4"])
    sir_drafts.map{|f| f.booster_order.map(&:code)}.should eq([
      ["sir-arena-1"] * 3,
      ["sir-arena-2"] * 3,
      ["sir-arena-3"] * 3,
      ["sir-arena-4"] * 3,
    ])
    sir_drafts.all?(&:describable_draft?).should eq(true)
    db.sets["pio"].limited_formats.map(&:type)
      .should eq(["arena-draft-1", "arena-draft-2", "arena-draft-3"])
  end

  # Formats the type doesn't describe well get their name and their
  # explanation out of the data file
  it "formats can name and describe themselves" do
    sir_draft = db.sets["sir"].limited_formats.find{|f| f.type == "arena-draft-2"}
    sir_draft.name.should eq("Shadows over Innistrad Remastered Arena Draft: Fatal Flashback")
    sir_draft.to_s.should eq(sir_draft.name)
    sir_draft.slug.should eq("arena-draft-2")
    sir_draft.description.should include("four drafts rather than one")
    # Formats which don't say get the name their type spells out, and no text
    nph_draft.name.should eq("New Phyrexia Draft")
    nph_draft.description.should eq(nil)
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
      PhysicalCard.for(db.sets["pnph"].printing_by_number["73★"], finish: :foil),
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
