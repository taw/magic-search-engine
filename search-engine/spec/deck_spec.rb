# Precon set => parent set its decks also take cards from.
# Mostly Commander sets, we don't model this relationship yet,
# so it should eventually move to data.
PRECON_SET_PARENTS = {
  "e01" => "akh",
  "c20" => "iko",
  "znc" => "znr",
  "khc" => "khm",
  "c21" => "stx",
  "afc" => "afr",
  "mic" => "mid",
  "voc" => "vow",
  "nec" => "neo",
  "ncc" => "snc",
  "dmc" => "dmu",
  "onc" => "one",
  "moc" => "mom",
  "ltc" => "ltr",
  "woc" => "woe",
  "lcc" => "lci",
  "mkc" => "mkm",
  "otc" => "otj",
  "m3c" => "mh3",
  "blc" => "blb",
  "dsc" => "dsk",
  "drc" => "dft",
  "tdc" => "tdm",
  "fic" => "fin",
  "eoc" => "eoe",
  "ecc" => "ecl",
  "tmc" => "tmt",
  "soc" => "sos",
  "msc" => "msh",
  "frc" => "fra",
}

describe Deck do
  include_context "db"

  # This is not great
  let(:precon_sets) do
    db
      .sets
      .values
      .select{|set|
        !([
        "archenemy", "commander", "duel deck", "planechase", "premium deck",
        ] & (set.types)).empty?
      }
      .select{|set|
        ![
          "cm1", "opca", "oe01", "ohop", "phop", "oarc", "parc", "opc2",
          "ocmd", "oc13", "oc14", "oc15", "oc16", "oc17", "oc18", "oc19", "oc20", "oc21",
          "cmr", "cc1", "cc2", "fdc",
        ].include?(set.code)
      }
  end

  it "precon decks have dates matching set release dates" do
    precon_sets.each do |set|
      set.decks.each do |deck|
        # New weird product, so far the only such case
        next if deck.type == "Box Set" and set.code == "ltc"
        deck.release_date.should eq(set.release_date), "#{deck.name} for #{set.name}"
      end
    end
  end

  it "all decks have release date" do
    db.decks.each do |deck|
      deck.release_date.should_not eq(nil), "#{deck.name} for #{deck.set.name}"
    end
  end

  # Decks may also contain cards from the precon set's oversized set (o + set code),
  # and from its parent set, listed in PRECON_SET_PARENTS
  it "cards in precon sets have no off-set cards" do
    precon_sets.each do |set|
      sets_found = set.decks.flat_map(&:physical_cards).map(&:set).map(&:code).uniq
      if set.code == "dd3"
        # product-only set
        sets_found.should match_array []
      elsif set.types.include?("preview")
        # skip it, as it might not have precons data yet
      else
        expected = [set.code, *PRECON_SET_PARENTS[set.code]]
        expected << "o#{set.code}" if db.sets["o#{set.code}"]
        sets_found.should match_array(expected), "#{set.code} #{set.name}"
      end
    end
  end

  # This test should check that all PhysicalCards match, but this fails as:
  # * we don't have any alt art information on decklist side (mostly for basic lands)
  # * we don't have any foil information, on either side
  #
  # This test fails for most new Commander sets, so just using date cutoff
  it "cards in precon sets are all in their precon decks" do
    precon_sets.each do |set|
      # Plane cards are technically not part of any precon in it
      next if set.code == "pca"
      # Contains some Amonkhet cards
      next if set.code == "e01"
      # Basically all new Commander decks contain cards from main set
      next if set.types.include?("commander") and set.release_date >= Date.parse("2020-04-17")

      # All names match both ways
      set_card_names = set.physical_card_names
      deck_card_names = set.decks.flat_map(&:physical_card_names).uniq

      # Special cases
      if set.code == "hop"
        # Release event promo
        set_card_names += db.sets["ohop"].physical_card_names
        set_card_names.should match_array deck_card_names
      elsif set.code == "pc2"
        set_card_names += db.sets["opc2"].physical_card_names
        set_card_names.should match_array deck_card_names
      elsif set.code == "arc"
        set_card_names += db.sets["oarc"].physical_card_names
        set_card_names.should match_array deck_card_names
      else
        unless set_card_names.to_set == deck_card_names.to_set
          warn "For precon set #{set.code}, cards do not match decklists (...and they won't for most new sets)"
        end
        binding.pry unless set_card_names.sort == deck_card_names.sort
        set_card_names.should match_array deck_card_names
      end
    end
  end

  it "deck names are unique for each set" do
    db.sets.each do |set_code, set|
      set.decks.map(&:name).should match_array set.decks.map(&:name).uniq
    end
  end

  it "deck slugs are unique for each set" do
    db.sets.each do |set_code, set|
      set.decks.map(&:slug).should match_array set.decks.map(&:slug).uniq
    end
  end

  it "if deck contains foils, they're all highest rarity cards" do
    db.sets.each do |set_code, set|
      # CM2 has 13 foils distributed in weird way
      if set_code == "cm2"
        foils = set.decks.flat_map(&:physical_cards).select(&:foil)
        foils_rarity = foils.map(&:main_front).map(&:rarity)
        foils_rarity.should match_array(["rare"] * 3 + ["mythic"] * 10)
        next
      end
      # PHED is 50:50 foil nonfoil, I'll just need to trust mtgjson here
      next if set_code == "phed"
      # PCTB is weird as well
      next if set_code == "pctb"
      # Not decks, just boxed products
      next if set_code == "sld"
      # Crazy foiling
      next if set_code == "pagl"
      # It's a weird box
      next if set_code == "fdn"

      # Some crazy foiling in them
      # Deck indexer doesn't even try, it's just marked on decklist manually
      next if set_code == "btd"
      next if set_code == "dkm"
      next if set_code == "gk1"
      next if set_code == "gk2"

      set.decks.each do |deck|
        if deck.type == "Clash Pack"
          foils = deck.physical_cards.select(&:foil)
          clash_pack_cards = deck.physical_cards.select{|c| c.set_code.start_with?('cp') }
          foils.should match_array(clash_pack_cards)
          next
        end

        # Some have foil basics
        next if deck.type == "Jumpstart"
        # Box not deck
        next if deck.type == "Welcome Booster"
        # basics and commons in foil too
        next if deck.name == "Final Fantasy Bundle Land Pack"

        # verified on WotC site, unusual rare foil instead of mythic, in just one deck
        next if deck.name == "Animated Army"

        # Exclude oversized cards from consideration
        deck_cards = deck.physical_cards.reject(&:oversized)

        foils = deck_cards.select(&:foil)
        # Skip if no foils
        next if foils.empty?
        # Skip if all foils
        next if deck_cards.all?(&:foil)

        max_rarity = deck_cards.map(&:main_front).max_by(&:rarity_code).rarity
        foils_rarity = foils.map(&:main_front).map(&:rarity)
        if set_code == "c16"
          # Doesn't follow normal rules
          foils_rarity.should match_array(["rare", "mythic", "mythic", "mythic"])
        elsif set_code == "who"
          # including with display commander
          foils_rarity.should match_array(["rare", "mythic", "mythic"])
        else
          expected_rarity = [max_rarity] * foils_rarity.size
          foils_rarity.should(
            eq(expected_rarity),
            "#{set.name} #{deck.name} foils should all be #{max_rarity}, instead they are: #{foils.map{|c| "#{c.name} (#{c.rarity})"}.join(", ")}"
          )
        end
      end
    end
  end

  it "Commander decks have valid commander" do
    db.decks.each do |deck|
      case deck.type
      when "Commander Deck", "MTGO Commander Deck"
        deck.should be_valid_commander
        # Brawler is superset of commander, so even though none of theme are Brawl decks, give it a go
        deck.should be_valid_brawler
      when "Brawl Deck", "Historic Brawl Precon Deck"
        # Not guaranteed but true so far
        deck.should be_valid_commander
        deck.should be_valid_brawler
      else
        deck.should_not be_valid_commander
        deck.should_not be_valid_brawler
      end
    end
  end

  describe "#cards_in_all_zones adds up mainboard and sideboard" do
    let(:deck) { db.sets["q02"].deck_named("United Assault") }
    let(:main) { deck.cards }
    let(:side) { deck.sideboard }
    let(:commander) { deck.commander }
    let(:all) { deck.cards_in_all_zones }
    let(:conclave_tribunal) {
      PhysicalCard.for db.search("Conclave Tribunal e:grn").printings.first
    }

    it do
      main.sum(&:first).should eq 60
      side.sum(&:first).should eq 15
      commander.sum(&:first).should eq 0
      all.sum(&:first).should eq 75
      main.should include [3, conclave_tribunal]
      side.should include [1, conclave_tribunal]
      all.should include [4, conclave_tribunal]
    end
  end

  describe "#cards_in_all_zones adds up mainboard and sideboard and commander" do
    let(:deck) { db.sets["eld"].deck_named("Savage Hunger") }
    let(:main) { deck.cards }
    let(:side) { deck.sideboard }
    let(:commander) { deck.commander }
    let(:all) { deck.cards_in_all_zones }
    let(:korvold) {
      PhysicalCard.for db.search("Korvold, Fae-Cursed King e:eld").printings.first, finish: :foil
    }

    it do
      main.sum(&:first).should eq 59
      side.sum(&:first).should eq 0
      commander.sum(&:first).should eq 1
      commander.should include [1, korvold]
      all.should include [1, korvold]
    end
  end

  # Including physical card full name here might be questionable API
  describe "#card_counts" do
    let(:united_assault) { db.sets["q02"].deck_named("United Assault") }
    let(:spiritbane) { db.sets["chk"].deck_named("Spiritbane") }
    let(:spiritcraft) { db.sets["bok"].deck_named("Spiritcraft") }
    let(:open_hostility) { db.sets["c16"].deck_named("Open Hostility") }

    it do
      united_assault.card_counts.should include([db.cards["conclave tribunal"], "Conclave Tribunal", 4])
      spiritbane.card_counts.should include([db.cards["brothers yamazaki"], "Brothers Yamazaki", 2])
      spiritcraft.card_counts.should include([db.cards["budoka pupil"], "Budoka Pupil // Ichiga, Who Topples Oaks", 1])
      spiritcraft.card_counts.should include([db.cards["faithful squire"], "Faithful Squire // Kaiso, Memory of Loyalty", 2])
      open_hostility.card_counts.should include([db.cards["order"], "Order // Chaos", 1])
    end
  end

  describe "#color_identity" do
    let(:open_hostility) { db.sets["c16"].deck_named("Open Hostility") }

    it "supports a single commander" do
      db.sets["cmd"].decks.map(&:color_identity).should match_array(["bgw", "bgu", "brw", "gru", "ruw"])
      db.sets["c13"].decks.map(&:color_identity).should match_array(["buw", "guw", "bru", "grw", "bgr"])
      db.sets["c14"].decks.map(&:color_identity).should match_array(["r", "w", "g", "u", "b"])
      db.sets["c15"].decks.map(&:color_identity).should match_array(["bw", "bg", "ru", "gu", "rw"])
      db.sets["c16"].decks.map(&:color_identity).should match_array(["bguw", "bgru", "bruw", "bgrw", "gruw"])
      db.sets["c17"].decks.map(&:color_identity).should match_array(["bru", "bgruw", "gw", "brw"])
      db.sets["c18"].decks.map(&:color_identity).should match_array(["guw", "ru", "bgr", "buw"])
    end

    it "supports partner commanders" do
      DeckParser.new(db, "COMMANDER: 1x Akiri, Line-Slinger\nCOMMANDER: 1x Ikra Shidiqi, the Usurper").deck.color_identity.should eq("bgrw")
      DeckParser.new(db, "COMMANDER: 1x Kydele, Chosen of Kruphix\nCOMMANDER: 1x Ikra Shidiqi, the Usurper").deck.color_identity.should eq("bgu")
    end
  end

  # Deck indexer can automacially insert missing [foil] in some cases, but it doesn't do comprehensive fixes
  describe "card finishes" do
    it "no cards with nonexistent finish" do
      db.decks.each do |deck|
        deck.cards_in_all_zones.map(&:last).each do |card|
          card.main_front.has_finish?(card.finish).should(be_truthy, "Card #{card.name} in #{deck.name} has invalid finish #{card.finish}")
        end
      end
    end
  end
end
