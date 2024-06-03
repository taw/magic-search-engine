describe Deck do
  include_context "db"

  # This is getting out of hand, and nseeds some cleanup
  it "each set has correct decks" do
    allowed_combinations = [
      # Completely unique types
      ["archenemy", "Archenemy Deck"],
      ["commander", "Commander Deck"],
      ["duel deck", "Duel Deck"],
      ["planechase", "Planechase Deck"],
      ["premium deck", "Premium Deck"],
      # Regular types
      ["box", "Duel Of The Planeswalkers Deck"],
      ["box", "Event Deck"],
      ["box", "Intro Pack"],
      ["box", "Theme Deck"],
      ["box", "Box Set"],
      ["masters", "MTGO Theme Deck"],
      ["global series", "Planeswalker Deck"], # v3
      ["duel deck", "Planeswalker Deck"], # v4
      ["board game deck", "Theme Deck"],
      ["box", "Game Night Deck"],
      ["pioneer", "Pioneer Challenger Deck"],
      ["standard", "Pioneer Challenger Deck"], # q08 listed under bro?
      # Standard sets
      ["core", "Clash Pack"],
      ["core", "Event Deck"],
      ["core", "Intro Pack"],
      ["core", "Theme Deck"],
      ["core", "Planeswalker Deck"],
      ["standard", "Welcome Deck"],
      ["expansion", "Advanced Deck"],
      ["expansion", "Enhanced Deck"],
      ["core", "Advanced Pack"],
      ["expansion", "Basic Deck"],
      ["expansion", "Clash Pack"],
      ["expansion", "Event Deck"],
      ["expansion", "Intro Pack"],
      ["expansion", "MTGO Theme Deck"],
      ["expansion", "Planeswalker Deck"],
      ["expansion", "Theme Deck"],
      ["expansion", "Brawl Deck"],
      ["standard", "Starter Deck"],
      ["starter", "Intro Pack"],
      ["box", "Guild Kit"],
      ["starter", "Starter Deck"],
      ["starter", "Theme Deck"],
      ["starter", "Welcome Deck"],
      ["starter", "Advanced Pack"],
      ["starter", "Welcome Booster"],
      ["expansion", "Challenger Deck"],
      ["core", "Challenger Deck"],
      ["box", "MTGO Theme Deck"], # MTGO
      ["box", "Commander Deck"], # MTGO
      ["core", "Spellslinger Starter Kit"],
      ["modern", "Modern Event Deck"],
      ["funny", "Halfdeck"],
      ["standard", "Halfdeck"],
      ["draft innovation", "Jumpstart"], # JMP only
      ["memorabilia", "World Championship Deck"], # WCxx
      ["memorabilia", "Pro Tour Deck"], # PTC
      ["expansion", "Jumpstart"],
      ["standard", "Arena Starter Kit"],
      ["standard", "Starter Kit"],
      ["standard", "Arena Starter Deck"],
      ["modern", "Starter Kit"], # LTR
      ["standard", "Arena Promotional Deck"],
      ["starter", "Arena Starter Deck"],
      ["modern", "Arena Starter Deck"], # LTR
      ["standard", "Deck Builder's Toolkit"],
      ["box", "Challenger Deck"], # Q07
      ["core", "Sample Deck"],
      ["shandalar", "Shandalar Enemy Deck"], # assigned to PAST, as there's no Shandalar set
      # Non-decks, this needs to be sorted out at some point
      ["box", "Box"],
      ["sld", "Secret Lair Drop"],
      ["core", "Welcome Booster"],
      ["expansion", "Welcome Booster"],
      ["commander", "Box Set"],
      ["standard", "Box Set"],
      ["fixed", "Box Set"],
      ["planechase", "Box Set"],
      ["promo", "Box Set"],
      ["funny", "Box Set"],
      ["memorabilia", "Box Set"],
      ["sdcc", "San Diego Comic Con Promos"],
    ]

    db.sets.each do |set_code, set|
      set.decks.each do |deck|
        allowed_set_types = allowed_combinations.select{|_,dt| dt == deck.type}.map(&:first)
        (allowed_set_types & set.types).should_not be_empty,
          "Deck #{deck.name} has type:\n  #{deck.type}\nIt is allowed for set types:\n  #{allowed_set_types.join(", ")}\nbut set #{set.code} #{set.name} has types:\n  #{set.types.join(", ")}"
      end
    end
  end

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
          "cmr", "cc1", "cc2",
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

  # This is basically false now and every XXX set now has XXc associated with it
  # It's arguably useful for checking no really weird card leaks
  it "cards in precon sets have no off-set cards" do
    precon_sets.each do |set|
      sets_found = set.decks.flat_map(&:physical_cards).map(&:set).map(&:code).uniq
      case set.code
      when "e01"
        # Contains some Amonkhet cards
        sets_found.should match_array ["e01", "akh", "oe01"]
      when "hop"
        sets_found.should match_array ["hop", "ohop"]
      when "arc"
        sets_found.should match_array ["arc", "oarc"]
      when "pc2"
        sets_found.should match_array ["pc2", "opc2"]
      when "c20"
        sets_found.should match_array ["c20", "iko", "oc20"]
      when "znc"
        sets_found.should match_array ["znr", "znc"]
      when "khc"
        sets_found.should match_array ["khm", "khc"]
      when "c21"
        sets_found.should match_array ["c21", "stx", "oc21"]
      when "afc"
        sets_found.should match_array ["afc", "afr"]
      when "mic"
        sets_found.should match_array ["mic", "mid"]
      when "voc"
        sets_found.should match_array ["voc", "vow"]
      when "nec"
        sets_found.should match_array ["nec", "neo"]
      when "ncc"
        sets_found.should match_array ["ncc", "snc"]
      when "dmc"
        sets_found.should match_array ["dmu", "dmc"]
      when "mkc"
        sets_found.should match_array ["mkc", "mkm"]
      when "onc"
        sets_found.should match_array ["onc", "one"]
      when "moc"
        sets_found.should match_array ["moc", "mom"]
      when "ltc"
        sets_found.should match_array ["ltc", "ltr"]
      when "pca"
        sets_found.should match_array ["pca", "opca"]
      when "woc"
        sets_found.should match_array ["woc", "woe"]
      when "lcc"
        sets_found.should match_array ["lcc", "lci"]
      when "cmd"
        sets_found.should match_array ["cmd", "ocmd"]
      when "c13"
        sets_found.should match_array ["c13", "oc13"]
      when "c14"
        sets_found.should match_array ["c14", "oc14"]
      when "c15"
        sets_found.should match_array ["c15", "oc15"]
      when "c16"
        sets_found.should match_array ["c16", "oc16"]
      when "c17"
        sets_found.should match_array ["c17", "oc17"]
      when "c18"
        sets_found.should match_array ["c18", "oc18"]
      when "c19"
        sets_found.should match_array ["c19", "oc19"]
      when "otc"
        sets_found.should match_array ["otc", "otj"]
      else
        sets_found.should eq [set.code]
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

  describe "#to_text" do
    let(:deck_export_wrath_of_mortals) do
      <<~EOF
      // NAME: Wrath of the Mortals - Journey into Nyx Event Deck
      // URL: http://mtg.wtf/deck/jou/wrath-of-the-mortals
      // DATE: 2014-05-23
      1 Battlefield Thaumaturge
      3 Young Pyromancer
      3 Guttersnipe
      1 Chandra's Phoenix
      4 Spellheart Chimera
      1 Ogre Battledriver
      1 Oracle of Bones
      1 Aetherling
      1 Harness by Force
      1 Mizzium Mortars
      2 Flames of the Firebrand
      2 Divination
      1 Anger of the Gods
      4 Lightning Strike
      3 Magma Jet
      2 Searing Blood
      1 Steam Augury
      1 Fated Conflagration
      2 Turn // Burn
      4 Izzet Guildgate
      12 Mountain
      9 Island

      Sideboard
      2 Flames of the Firebrand
      2 Elixir of Immortality
      2 Dispel
      3 Essence Scatter
      3 Negate
      3 Izzet Staticaster
      EOF
    end

    let(:deck_export_blast_from_the_past) do
      <<~EOF
      // NAME: Blast from the Past - Doctor Who Commander Deck
      // URL: http://mtg.wtf/deck/who/blast-from-the-past
      // DATE: 2023-10-13
      COMMANDER: 1 The Fourth Doctor
      COMMANDER: 1 Sarah Jane Smith
      1 Romana II
      1 Jo Grant
      1 Tegan Jovanka
      1 Barbara Wright
      1 Ian Chesterton
      1 Peri Brown
      1 Crisis of Conscience
      1 The Caves of Androzani
      1 The War Games
      1 Trial of a Time Lord
      1 The Night of the Doctor
      1 Traverse Eternity
      1 K-9, Mark I
      1 Adric, Mathematical Genius
      1 Nyssa of Traken
      1 Reverse the Polarity
      1 Five Hundred Year Diary
      1 An Unearthly Child
      1 Leela, Sevateem Warrior
      1 Ace, Fearless Rebel
      1 Susan Foreman
      1 The Five Doctors
      1 Jamie McCrimmon
      1 The Sea Devils
      1 City of Death
      1 Gallifrey Stands
      1 Alistair, the Brigadier
      1 The First Doctor
      1 The Second Doctor
      1 The Third Doctor
      1 The Fifth Doctor
      1 The Sixth Doctor
      1 The Seventh Doctor
      1 The Eighth Doctor
      1 Vrestin, Menoptra Leader
      1 Sergeant John Benton
      1 The Curse of Fenric
      1 Duggan, Private Detective
      1 Bessie, the Doctor's Roadster
      1 Ace's Baseball Bat
      1 Gallifrey Council Chamber
      1 Day of Destiny
      1 Heroic Intervention
      1 Time Wipe
      1 Heroes' Podium
      1 Trenzalore Clocktower
      1 Twice Upon a Time // Unlikely Meeting
      1 Port Town
      1 Exotic Orchard
      1 Temple of Enlightenment
      1 Fortified Village
      1 Prairie Stream
      1 Canopy Vista
      1 Sungrass Prairie
      1 Temple of Plenty
      1 Irrigated Farmland
      1 Temple of Mystery
      1 Vineglimmer Snarl
      1 Scattered Groves
      1 Celestial Colonnade
      1 Deserted Beach
      1 Glacial Fortress
      1 Horizon Canopy
      1 Overgrown Farmland
      1 Waterlogged Grove
      1 Dreamroot Cascade
      1 Skycloud Expanse
      1 Banish to Another Universe
      1 Time Lord Regeneration
      1 Displaced Dinosaurs
      1 Sonic Screwdriver
      1 TARDIS
      1 Swords to Plowshares
      1 Path to Exile
      1 Return to Dust
      1 Explore
      1 Three Visits
      1 Arcane Signet
      1 Sol Ring
      1 Talisman of Unity
      1 Hero's Blade
      1 Talisman of Progress
      1 Thought Vessel
      1 Mind Stone
      1 Thriving Isle
      1 Thriving Grove
      1 Thriving Heath
      1 Ash Barrens
      1 Seaside Citadel
      1 Command Tower
      1 Path of Ancestry
      2 Plains
      2 Island
      3 Forest

      Planar Deck
      1 The Pyramid of Mars
      1 Caught in a Parallel Universe
      1 Gardens of Tranquil Repose
      1 Spectrox Mines
      1 Coal Hill School
      1 UNIT Headquarters
      1 The Cheetah Planet
      1 Antarctic Research Base
      1 The Cave of Skulls
      1 TARDIS Bay

      Display Commander
      1 The Fourth Doctor
      EOF
    end

    it "works for normal decks" do
      deck = db.sets["jou"].deck_named("Wrath of the Mortals")
      deck.to_text.should eq(deck_export_wrath_of_mortals)
    end

    it "handles extra sections" do
      deck = db.sets["who"].deck_named("Blast from the Past")
      deck.to_text.should eq(deck_export_blast_from_the_past)
    end
  end

  it "CardDatabase#decks_containing" do
    c15_basic_forests = db.search("e:c15 ++ t:basic t:forest").printings
    c15_basic_forests.size.should eq(4)
    green_c15_decks = [
      "Plunder the Graves",
      "Swell the Host",
    ]
    c15_basic_forests.each do |forest|
      db.decks_containing(forest).map(&:name).should match_array(green_c15_decks)
    end

    som_arc_trail = db.search("e:som arc trail").printings[0]
    db.decks_containing(som_arc_trail).map{|deck| [deck.set_name, deck.name, deck.type] }.should eq([
      ["Scars of Mirrodin", "Relic Breaker", "Intro Pack"],
      ["Mirrodin Besieged", "Mirromancy", "Intro Pack"],
      ["Magic 2012", "Red Deck A", "Sample Deck"],
      ["Dark Ascension", "Gleeful Flames", "Event Deck"],
      ["Magic 2013", "Sweet Revenge", "Event Deck"],
    ])
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
      if deck.type == "Commander Deck"
        deck.should be_valid_commander
        # Brawler is superset of commander, so even though none of theme are Brawl decks, give it a go
        deck.should be_valid_brawler
      elsif deck.type == "Brawl Deck"
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
    let(:deck) { db.sets["eld"].deck_named("Savage Hunter") }
    let(:main) { deck.cards }
    let(:side) { deck.sideboard }
    let(:commander) { deck.commander }
    let(:all) { deck.cards_in_all_zones }
    let(:korvold) {
      PhysicalCard.for db.search("Korvold, Fae-Cursed King e:eld").printings.first, true
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
end
