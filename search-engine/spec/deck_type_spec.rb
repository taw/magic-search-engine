# This specs validates data coming from magic-preconstructed-decks, against mtgjson and ours set types
describe "Deck types" do
  include_context "db"

  # This is getting out of hand, and needs some cleanup
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
      ["expansion", "Clash Pack"],
      ["expansion", "Basic Deck"],
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
      ["box", "MTGO Theme Deck"],
      ["box", "MTGO Commander Deck"],
      ["sld", "Commander Deck"],
      ["duel deck", "MTGO Duel Deck"],
      ["core", "Spellslinger Starter Kit"],
      ["modern", "Modern Event Deck"],
      ["funny", "Halfdeck"],
      ["standard", "Halfdeck"],
      ["draft innovation", "Jumpstart"], # JMP only
      ["memorabilia", "World Championship Deck"], # WCxx
      ["memorabilia", "Pro Tour Deck"], # PTC
      ["expansion", "Jumpstart"],
      ["eternal", "Jumpstart"], # TLE
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
      ["standard", "Historic Brawl Precon Deck"],
      ["shandalar", "Shandalar Enemy Deck"], # assigned to PAST, as there's no Shandalar set
      ["core", "Jumpstart"], # FDN
      ["starter", "Demo Deck"],
      ["core", "Demo Deck"],
      ["expansion", "Enemy Deck"],
      ["sld", "Dandan Deck"],
      ["memorabilia", "Challenge Deck"],
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
      ["core", "MTGO Redemption"],
      ["expansion", "MTGO Redemption"],
      ["eternal", "Box Set"],
      ["standard", "Bundle Land Pack"],
      ["modern", "Bundle Land Pack"],
      ["commander", "Bundle Land Pack"],
      ["promo", "Bundle Land Pack"], # P15A
      ["core", "Booster Battle Pack Packet"], # M12, M13
    ]

    db.sets.each do |set_code, set|
      set.decks.each do |deck|
        allowed_set_types = allowed_combinations.select{|_,dt| dt == deck.type}.map(&:first)
        (allowed_set_types & set.types).should_not be_empty,
          "#{set.name} deck #{deck.name} has type:\n  #{deck.type}\nIt is allowed for set types:\n  #{allowed_set_types.join(", ")}\nbut set #{set.code} #{set.name} has types:\n  #{set.types.join(", ")}"
      end
    end
  end
end
