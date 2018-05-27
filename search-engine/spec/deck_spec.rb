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
      # Standard sets
      ["core", "Clash Pack"],
      ["core", "Event Deck"],
      ["core", "Intro Pack"],
      ["core", "Theme Deck"],
      ["expansion", "Advanced Deck"],
      ["expansion", "Basic Deck"],
      ["expansion", "Clash Pack"],
      ["expansion", "Event Deck"],
      ["expansion", "Intro Pack"],
      ["expansion", "MTGO Theme Deck"],
      ["expansion", "Planeswalker Deck"],
      ["expansion", "Theme Deck"],
      ["starter", "Intro Pack"],
      ["starter", "Starter Deck"],
      ["starter", "Theme Deck"],
      ["starter", "Welcome Deck"],
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
      ].include?(set.type) and set_code != "cm1"
    end
  end

  it "cards in precon sets have no off-set cards" do
    precon_sets.each do |set_code, set|
      # Contains some Amonkhet cards
      next if set_code == "e01"
      set.decks.flat_map(&:physical_cards).map(&:set).map(&:code).uniq.should eq [set_code]
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
      set_card_names = set.physical_cards.map(&:name).uniq
      deck_card_names = set.decks.flat_map(&:physical_cards).map(&:name).uniq

      # Special cases
      if set_code == "pch"
        # Release event promo
        set_card_names.should match_array ["Tazeem", *deck_card_names]
      elsif set_code == "pc2"
        set_card_names.should match_array ["Stairs to Infinity", *deck_card_names]
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
end
