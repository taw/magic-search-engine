describe "Deck legality" do
  include_context "db"

  it "allowed_in_any_number?" do
    db.printings.select(&:allowed_in_any_number?).map(&:name).uniq.should match_array([
      "Forest",
      "Island",
      "Mountain",
      "Persistent Petitioners",
      "Plains",
      "Rat Colony",
      "Relentless Rats",
      "Shadowborn Apostle",
      "Snow-Covered Forest",
      "Snow-Covered Island",
      "Snow-Covered Mountain",
      "Snow-Covered Plains",
      "Snow-Covered Swamp",
      "Swamp",
      "Wastes",
    ])
  end

  describe "valid_commander" do
    it "empty is not valid" do
      assert_invalid_commander
    end

    it "2 of the same are invalid" do
      assert_invalid_commander "2x Urabrask the Hidden"
      assert_invalid_commander "2x Rowan Kenrith"
      assert_invalid_commander "2x Bruse Tarl, Boorish Herder"
    end

    it "3 or more are invalid" do
      assert_invalid_commander "Emrakul, the Aeons Torn", "Urabrask the Hidden", "Isperia, Supreme Judge"
    end

    it "nonlegendary is invalid" do
      assert_invalid_commander "Etched Monstrosity"
      assert_invalid_commander "Goblin Guide"
    end

    it "noncreature is invalid" do
      assert_invalid_commander "Blackblade Reforged"
    end

    it "secondary doesn't count, deck parser will flip to front side if you ask for secondary" do
      assert_invalid_commander "Autumn-Tail, Kitsune Sage"
      assert_invalid_commander "Withengar Unbound"

      assert_valid_commander "Archangel Avacyn"
      # Deck parser changes is to Archangel Avacyn, which is totally fine
      assert_valid_commander "Avacyn, the Purifier"

      assert_valid_commander "Bruna, the Fading Light"
      assert_valid_commander "Gisela, the Broken Blade"
      # Deck parser changes this to Bruna, the Fading Light, which is questionable
      assert_valid_commander "Brisela, Voice of Nightmares"
    end

    it "is valid if primary side is valid" do
      assert_valid_commander "Chandra, Roaring Flame"
    end

    it "legendary creature in any colors is valid" do
      assert_valid_commander "Emrakul, the Aeons Torn"
      assert_valid_commander "Urabrask the Hidden"
      assert_valid_commander "Isperia, Supreme Judge"
      assert_valid_commander "Glissa, the Traitor"
      assert_valid_commander "Breya, Etherium Shaper"
      assert_valid_commander "Niv-Mizzet Reborn"
    end

    it "planeswalkers are only valid if they say so" do
      assert_valid_brawler_only "Tibalt, the Fiend-Blooded"
      assert_valid_brawler_only "Karn Liberated"
      assert_valid_commander "Nahiri, the Lithomancer"
    end

    it "Commander partners are valid alone or with another partner" do
      assert_valid_commander "Bruse Tarl, Boorish Herder"
      assert_valid_commander "Sidar Kondo of Jamuraa"
      assert_valid_commander "Bruse Tarl, Boorish Herder", "Sidar Kondo of Jamuraa"
      assert_invalid_commander "Bruse Tarl, Boorish Herder", "Karn, Silver Golem"
    end

    it "BBD partners are valid alone or with designated partner" do
      assert_valid_commander "Rowan Kenrith"
      assert_valid_commander "Will Kenrith"
      assert_valid_commander "Rowan Kenrith", "Will Kenrith"
      assert_valid_commander "Virtus the Veiled"
      assert_valid_commander "Gorm the Great"
      assert_valid_commander "Gorm the Great", "Virtus the Veiled"
      assert_invalid_commander "Rowan Kenrith", "Gorm the Great"
      assert_invalid_commander "Ravos, Soultender", "Gorm the Great"
      assert_invalid_commander "Glissa, the Traitor", "Gorm the Great"
      assert_invalid_commander "Gorm the Great", "Rowan Kenrith"
      assert_invalid_commander "Gorm the Great", "Ravos, Soultender"
      assert_invalid_commander "Gorm the Great", "Glissa, the Traitor"
    end

    it "non-legendary BBD partners are not valid" do
      assert_invalid_commander "Blaring Captain"
      assert_invalid_commander "Blaring Captain", "Blaring Recruiter"
    end

    it "exact printing doesn't matter" do
      assert_valid_commander "1x [BBD:255] [foil] Rowan Kenrith", "1x [BBD:2] Will Kenrith"
      assert_valid_commander "1x [PBBD:255s] [foil] Rowan Kenrith", "1x [BBD:2] Will Kenrith"
    end

    it "uncards are valid" do
      assert_valid_commander "Richard Garfield, Ph.D."
      assert_valid_brawler_only "Urza, Academy Headmaster"
    end
  end

  def parse_deck_for_commander(*cards)
    decklist = "100x Forest\n\nSideboard\n" + cards.join("\n") + "\n"
    parser = DeckParser.new(db, decklist)
    Deck.new(parser.main_cards, parser.sideboard_cards)
  end


  def assert_valid_commander(*cards)
    deck = parse_deck_for_commander(*cards)
    deck.should be_valid_commander
    deck.should be_valid_brawler
  end

  def assert_valid_brawler_only(*cards)
    deck = parse_deck_for_commander(*cards)
    deck.should_not be_valid_commander
    deck.should be_valid_brawler
  end

  def assert_invalid_commander(*cards)
    deck = parse_deck_for_commander(*cards)
    deck.should_not be_valid_commander
    deck.should_not be_valid_brawler
  end
end
