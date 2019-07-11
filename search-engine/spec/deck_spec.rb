describe Deck do
  include_context "db"

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
      ["masters", "MTGO Theme Deck"],
      ["global series", "Planeswalker Deck"], # v3
      ["duel deck", "Planeswalker Deck"], # v4
      ["board game deck", "Theme Deck"],
      ["box", "Game Night Deck"],
      # Standard sets
      ["core", "Clash Pack"],
      ["core", "Event Deck"],
      ["core", "Intro Pack"],
      ["core", "Theme Deck"],
      ["core", "Planeswalker Deck"],
      ["core", "Welcome Deck"],
      ["expansion", "Advanced Deck"],
      ["expansion", "Basic Deck"],
      ["expansion", "Clash Pack"],
      ["expansion", "Event Deck"],
      ["expansion", "Intro Pack"],
      ["expansion", "MTGO Theme Deck"],
      ["expansion", "Planeswalker Deck"],
      ["expansion", "Theme Deck"],
      ["starter", "Intro Pack"],
      ["box", "Guild Kit"],
      ["starter", "Starter Deck"],
      ["starter", "Theme Deck"],
      ["starter", "Welcome Deck"],
      ["starter", "Advanced Pack"],
      ["expansion", "Challenger Deck"],
      ["box", "MTGO Theme Deck"], # MTGO
      ["box", "Commander Deck"], # MTGO
      ["core", "Spellslinger Starter Kit"],
    ]

    db.sets.each do |set_code, set|
      set.decks.each do |deck|
        allowed_combinations.should include([set.type, deck.type])
      end
    end
  end

  let(:precon_sets) do
    db.sets.select do |set_code, set|
      # CM1 is a Commander product without precon decks
      [
        "archenemy", "commander", "duel deck", "planechase", "premium deck",
      ].include?(set.type) and ![
        "cm1", "opca", "oe01", "ohop", "phop", "oarc", "parc", "opc2",
      ].include?(set_code)
    end
  end

  it "precon decks have dates matching set release dates" do
    precon_sets.each do |set_code, set|
      set.decks.each do |deck|
        deck.release_date.should eq(set.release_date), "#{deck.name} for #{set.name}"
      end
    end
  end

  it "cards in precon sets have no off-set cards" do
    precon_sets.each do |set_code, set|
      sets_found = set.decks.flat_map(&:physical_cards).map(&:set).map(&:code).uniq
      # Contains some Amonkhet cards
      case set_code
      when "e01"
        sets_found.should match_array ["e01", "akh", "oe01"]
      when "hop"
        sets_found.should match_array ["hop", "ohop"]
      when "arc"
        sets_found.should match_array ["arc", "oarc"]
      when "pc2"
        sets_found.should match_array ["pc2", "opc2"]
      else
        sets_found.should eq [set_code]
      end
    end
  end

  # This test should check that all PhysicalCards match, but this fails as:
  # * we don't have any alt art information on decklist side (mostly for basic lands)
  # * we don't have any foil information, on either side
  it "cards in precon sets are all in their precon decks" do
    precon_sets.each do |set_code, set|
      # Plane cards are technically not part of any precon in it
      next if set_code == "pca"
      # Contains some Amonkhet cards
      next if set_code == "e01"

      # All names match both ways
      set_card_names = set.physical_card_names
      deck_card_names = set.decks.flat_map(&:physical_card_names).uniq

      # Special cases
      if set_code == "hop"
        # Release event promo
        set_card_names += db.sets["ohop"].physical_card_names
        set_card_names.should match_array deck_card_names
      elsif set_code == "pc2"
        set_card_names += db.sets["opc2"].physical_card_names
        set_card_names.should match_array deck_card_names
      elsif set_code == "arc"
        set_card_names += db.sets["oarc"].physical_card_names
        set_card_names.should match_array deck_card_names
      else
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

  let(:deck_export) do
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

  it "#to_text" do
    deck = db.sets["jou"].decks.find{|d| d.name == "Wrath of the Mortals"}
    deck.to_text.should eq(deck_export)
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

      # Some crazy foiling in them
      # Deck indexer doesn't even try, it's just marked on decklist manually
      next if set_code == "btd"
      next if set_code == "dkm"
      next if set_code == "gk1"
      next if set_code == "gk2"

      set.decks.each do |deck|
        if deck.type == "Clash Pack"
          foils = deck.physical_cards.select(&:foil)
          clash_pack_cards = deck.physical_cards.select{|c| c.set_code =~ /\Acp/ }
          foils.should match_array(clash_pack_cards)
          next
        end

        foils = deck.physical_cards.select(&:foil)
        # Skip if no foils
        next if foils.empty?
        # Skip if all foils
        next if deck.physical_cards.all?(&:foil)

        max_rarity = deck.physical_cards.map(&:main_front).max_by(&:rarity_code).rarity
        foils_rarity = foils.map(&:main_front).map(&:rarity)
        if set_code == "c16"
          # Doesn't follow normal rules
          foils_rarity.should match_array(["rare", "mythic", "mythic", "mythic"])
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
      else
        deck.should_not be_valid_commander
        deck.should_not be_valid_brawler
      end
    end
  end

  describe "#cards_with_sideboard adds up mainboard and sideboard" do
    let(:deck) { db.sets["grn"].decks.find{|d| d.name == "United Assault" } }
    let(:main) { deck.cards }
    let(:side) { deck.sideboard }
    let(:all) { deck.cards_with_sideboard }
    let(:conclave_tribunal) {
      PhysicalCard.for db.search("Conclave Tribunal e:grn").printings.first
    }

    it do
      main.sum(&:first).should eq 60
      side.sum(&:first).should eq 15
      all.sum(&:first).should eq 75
      main.should include [3, conclave_tribunal]
      side.should include [1, conclave_tribunal]
      all.should include [4, conclave_tribunal]
    end
  end
end
