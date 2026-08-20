describe DeckExporter do
  include_context "db"

  describe "card names only" do
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
      deck.export("names").text.should eq(deck_export_wrath_of_mortals)
    end

    it "handles extra sections" do
      deck = db.sets["who"].deck_named("Blast from the Past")
      deck.export("names").text.should eq(deck_export_blast_from_the_past)
    end
  end

  describe "text" do
    let(:deck_export_wrath_of_mortals) do
      <<~EOF
      // NAME: Wrath of the Mortals - Journey into Nyx Event Deck
      // URL: http://mtg.wtf/deck/jou/wrath-of-the-mortals
      // DATE: 2014-05-23
      1 Battlefield Thaumaturge [JOU:31]
      3 Young Pyromancer [M14:163]
      3 Guttersnipe [RTR:98]
      1 Chandra's Phoenix [M14:134]
      4 Spellheart Chimera [THS:204]
      1 Ogre Battledriver [M14:148]
      1 Oracle of Bones [BNG:103]
      1 Aetherling [DGM:11]
      1 Harness by Force [JOU:100]
      1 Mizzium Mortars [RTR:101]
      2 Flames of the Firebrand [M14:139]
      2 Divination [BNG:36]
      1 Anger of the Gods [THS:112]
      4 Lightning Strike [THS:127]
      3 Magma Jet [THS:128]
      2 Searing Blood [BNG:111]
      1 Steam Augury [THS:205]
      1 Fated Conflagration [BNG:94]
      2 Turn // Burn [DGM:134a]
      4 Izzet Guildgate [DGM:151]
      3 Mountain [THS:242]
      3 Mountain [THS:243]
      3 Mountain [THS:244]
      3 Mountain [THS:245]
      3 Island [THS:234]
      2 Island [THS:235]
      2 Island [THS:236]
      2 Island [THS:237]

      Sideboard
      2 Flames of the Firebrand [M14:139]
      2 Elixir of Immortality [M14:209]
      2 Dispel [RTR:36]
      3 Essence Scatter [M14:55]
      3 Negate [M14:64]
      3 Izzet Staticaster [RTR:173]
      EOF
    end

    let(:deck_export_blast_from_the_past) do
      <<~EOF
      // NAME: Blast from the Past - Doctor Who Commander Deck
      // URL: http://mtg.wtf/deck/who/blast-from-the-past
      // DATE: 2023-10-13
      COMMANDER: 1 The Fourth Doctor [WHO:2] [foil]
      COMMANDER: 1 Sarah Jane Smith [WHO:6] [foil]
      1 Romana II [WHO:27]
      1 Jo Grant [WHO:23]
      1 Tegan Jovanka [WHO:28]
      1 Barbara Wright [WHO:14]
      1 Ian Chesterton [WHO:22]
      1 Peri Brown [WHO:26]
      1 Crisis of Conscience [WHO:17]
      1 The Caves of Androzani [WHO:15]
      1 The War Games [WHO:30]
      1 Trial of a Time Lord [WHO:29]
      1 The Night of the Doctor [WHO:24]
      1 Traverse Eternity [WHO:60]
      1 K-9, Mark I [WHO:47]
      1 Adric, Mathematical Genius [WHO:33]
      1 Nyssa of Traken [WHO:51]
      1 Reverse the Polarity [WHO:54]
      1 Five Hundred Year Diary [WHO:42]
      1 An Unearthly Child [WHO:35]
      1 Leela, Sevateem Warrior [WHO:107]
      1 Ace, Fearless Rebel [WHO:98]
      1 Susan Foreman [WHO:110]
      1 The Five Doctors [WHO:101]
      1 Jamie McCrimmon [WHO:105]
      1 The Sea Devils [WHO:108]
      1 City of Death [WHO:99]
      1 Gallifrey Stands [WHO:132]
      1 Alistair, the Brigadier [WHO:112]
      1 The First Doctor [WHO:128]
      1 The Second Doctor [WHO:156]
      1 The Third Doctor [WHO:162]
      1 The Fifth Doctor [WHO:127]
      1 The Sixth Doctor [WHO:159]
      1 The Seventh Doctor [WHO:158]
      1 The Eighth Doctor [WHO:124]
      1 Vrestin, Menoptra Leader [WHO:166]
      1 Sergeant John Benton [WHO:157]
      1 The Curse of Fenric [WHO:118]
      1 Duggan, Private Detective [WHO:123]
      1 Bessie, the Doctor's Roadster [WHO:171]
      1 Ace's Baseball Bat [WHO:170]
      1 Gallifrey Council Chamber [WHO:188]
      1 Day of Destiny [WHO:206]
      1 Heroic Intervention [WHO:233]
      1 Time Wipe [WHO:238]
      1 Heroes' Podium [WHO:242]
      1 Trenzalore Clocktower [WHO:190]
      1 Twice Upon a Time // Unlikely Meeting [WHO:61a]
      1 Port Town [WHO:294]
      1 Exotic Orchard [WHO:276]
      1 Temple of Enlightenment [WHO:315]
      1 Fortified Village [WHO:280]
      1 Prairie Stream [WHO:295]
      1 Canopy Vista [WHO:258]
      1 Sungrass Prairie [WHO:311]
      1 Temple of Plenty [WHO:319]
      1 Irrigated Farmland [WHO:288]
      1 Temple of Mystery [WHO:318]
      1 Vineglimmer Snarl [WHO:329]
      1 Scattered Groves [WHO:301]
      1 Celestial Colonnade [WHO:260]
      1 Deserted Beach [WHO:270]
      1 Glacial Fortress [WHO:285]
      1 Horizon Canopy [WHO:287]
      1 Overgrown Farmland [WHO:292]
      1 Waterlogged Grove [WHO:331]
      1 Dreamroot Cascade [WHO:273]
      1 Skycloud Expanse [WHO:306]
      1 Banish to Another Universe [WHO:13]
      1 Time Lord Regeneration [WHO:59]
      1 Displaced Dinosaurs [WHO:100]
      1 Sonic Screwdriver [WHO:184]
      1 TARDIS [WHO:187]
      1 Swords to Plowshares [WHO:212]
      1 Path to Exile [WHO:210]
      1 Return to Dust [WHO:211]
      1 Explore [WHO:231]
      1 Three Visits [WHO:235]
      1 Arcane Signet [WHO:239]
      1 Sol Ring [WHO:245]
      1 Talisman of Unity [WHO:254]
      1 Hero's Blade [WHO:241]
      1 Talisman of Progress [WHO:253]
      1 Thought Vessel [WHO:255]
      1 Mind Stone [WHO:244]
      1 Thriving Isle [WHO:327]
      1 Thriving Grove [WHO:325]
      1 Thriving Heath [WHO:326]
      1 Ash Barrens [WHO:257]
      1 Seaside Citadel [WHO:302]
      1 Command Tower [WHO:263]
      1 Path of Ancestry [WHO:293]
      1 Plains [WHO:196]
      1 Plains [WHO:197]
      1 Island [WHO:198]
      1 Island [WHO:199]
      2 Forest [WHO:204]
      1 Forest [WHO:205]

      Planar Deck
      1 The Pyramid of Mars [WHO:597]
      1 Caught in a Parallel Universe [WHO:572]
      1 Gardens of Tranquil Repose [WHO:583]
      1 Spectrox Mines [WHO:599]
      1 Coal Hill School [WHO:576]
      1 UNIT Headquarters [WHO:604]
      1 The Cheetah Planet [WHO:574]
      1 Antarctic Research Base [WHO:567]
      1 The Cave of Skulls [WHO:573]
      1 TARDIS Bay [WHO:601]

      Display Commander
      1 The Fourth Doctor [WHO:193] [foil] [etched]
      EOF
    end

    it "works for normal decks" do
      deck = db.sets["jou"].deck_named("Wrath of the Mortals")
      deck.export("text").text.should eq(deck_export_wrath_of_mortals)
    end

    it "handles extra sections" do
      deck = db.sets["who"].deck_named("Blast from the Past")
      deck.export("text").text.should eq(deck_export_blast_from_the_past)
    end
  end

  # Small decks built out of the cases every format disagrees about, instead of
  # a fixture per deck per format
  let(:deck) { DeckParser.new(db, decklist).deck }

  describe "cards whose faces have separate names" do
    let(:decklist) do
      <<~EOF
      4 Delver of Secrets (ISD) 51
      2 Fire // Ice (APC) 128
      1 Besotted Knight (WOE) 4
      1 Akki Lavarunner (CHK) 153
      1 Appeal // Authority (HOU) 152
      1 Valki, God of Lies (KHM) 114
      EOF
    end

    it "our own format numbers each face" do
      deck.export("text").text.should eq(<<~EOF)
      4 Delver of Secrets [ISD:51a]
      2 Fire // Ice [APC:128a]
      1 Besotted Knight // Betroth the Beast [WOE:4a]
      1 Akki Lavarunner // Tok-Tok, Volcano Born [CHK:153a]
      1 Appeal // Authority [HOU:152a]
      1 Valki, God of Lies [KHM:114a]
      EOF
    end

    it "arena style numbers the physical card, and names its front" do
      deck.export("arena").text.should eq(<<~EOF)
      Deck
      4 Delver of Secrets (ISD) 51
      2 Fire // Ice (APC) 128
      1 Besotted Knight // Betroth the Beast (WOE) 4
      1 Akki Lavarunner // Tok-Tok, Volcano Born (CHK) 153
      1 Appeal // Authority (HOU) 152
      1 Valki, God of Lies (KHM) 114
      EOF
    end

    # XMage joins split and aftermath cards only, and looks a name up exactly
    it "xmage names an adventure and a flip card after their front face" do
      deck.export("xmage").text.should eq(<<~EOF)
      4 [ISD:51] Delver of Secrets
      2 [APC:128] Fire // Ice
      1 [WOE:4] Besotted Knight
      1 [CHK:153] Akki Lavarunner
      1 [HOU:152] Appeal // Authority
      1 [KHM:114] Valki, God of Lies
      EOF
    end

    # Cockatrice joins adventures too, but not flip cards
    it "cockatrice keeps adventures joined and splits flip cards" do
      names(deck.export("cockatrice").text).should eq([
        "Delver of Secrets",
        "Fire // Ice",
        "Besotted Knight // Betroth the Beast",
        "Akki Lavarunner",
        "Appeal // Authority",
        "Valki, God of Lies",
      ])
    end

    # MTGO writes its split cards with a bare slash
    it "mtgo names cards the way MTGO does" do
      names(deck.export("mtgo").text).should eq([
        "Delver of Secrets",
        "Fire/Ice",
        "Besotted Knight",
        "Akki Lavarunner",
        "Appeal/Authority",
        "Valki, God of Lies",
      ])
    end

    it "csv quotes any name with a comma in it" do
      deck.export("csv").text.should eq(<<~EOF.gsub("\n", "\r\n"))
      Section,Count,Name,Set code,Set name,Collector number,Finish
      Main Deck,4,Delver of Secrets,ISD,Innistrad,51,Normal
      Main Deck,2,Fire // Ice,APC,Apocalypse,128,Normal
      Main Deck,1,Besotted Knight // Betroth the Beast,WOE,Wilds of Eldraine,4,Normal
      Main Deck,1,"Akki Lavarunner // Tok-Tok, Volcano Born",CHK,Champions of Kamigawa,153,Normal
      Main Deck,1,Appeal // Authority,HOU,Hour of Devastation,152,Normal
      Main Deck,1,"Valki, God of Lies",KHM,Kaldheim,114,Normal
      EOF
    end
  end

  describe "finishes" do
    let(:decklist) do
      <<~EOF
      1 Sol Ring (C21) 263 *F*
      1 Jeweled Lotus (CMR) 319 *E*
      EOF
    end

    it "our own format tags them, arena style marks them, csv has a column" do
      deck.export("text").text.should eq("1 Sol Ring [C21:263] [foil]\n1 Jeweled Lotus [CMR:319] [etched]\n")
      deck.export("arena").text.should eq("Deck\n1 Sol Ring (C21) 263 *F*\n1 Jeweled Lotus (CMR) 319 *E*\n")
      deck.export("csv").text.lines.map(&:chomp).map{|line| line.split(",").last }.should eq(["Finish", "Foil", "Etched"])
    end

    it "the formats which cannot say so warn about it" do
      %W[xmage cockatrice mtgo].each do |format|
        deck.export(format).warnings.should eq([
          "Exported as normal cards, as the format cannot mark a finish: Jeweled Lotus, Sol Ring",
        ])
      end
      deck.export("arena").warnings.should eq([])
      deck.export("csv").warnings.should eq([])
    end
  end

  describe "cards we do not know" do
    let(:decklist) { "1 Delver of Secrets (ISD) 51\n3 Not A Real Card\n" }

    it "exports the name and nothing else" do
      deck.export("arena").text.should eq("Deck\n1 Delver of Secrets (ISD) 51\n3 Not A Real Card\n")
      deck.export("csv").text.should include("Main Deck,3,Not A Real Card,,,,\r\n")
      # No set, no number, and no uuid either
      deck.export("cockatrice").text.should include(%Q[<card number="3" name="Not A Real Card"/>])
    end

    it "warns, because most formats will drop them" do
      deck.export("arena").warnings.should eq([
        "Not in our database, so exported without printing information: Not A Real Card",
      ])
      deck.export("xmage").warnings.should eq([
        "Not in our database, so XMage will skip: Not A Real Card",
      ])
      deck.export("mtgo").warnings.should eq([
        "Not on MTGO, so left out: Not A Real Card",
      ])
    end
  end

  describe "sections no other format has" do
    let(:deck) { db.sets["who"].deck_named("Blast from the Past") }

    it "arena style keeps the commander and merges the rest" do
      text = deck.export("arena").text
      text.should include("Commander\n1 The Fourth Doctor (WHO) 2 *F*\n")
      text.should include("\nDeck\n")
      text.should include("\nSideboard\n")
      deck.export("arena").warnings.should include(
        "Planar Deck cards go to the sideboard, as the format has no planar deck",
        "Display Commander left out, as it is an oversized copy of a card the deck already has",
      )
    end

    it "two zone formats put the commander in the sideboard" do
      deck.export("xmage").text.should include("SB: 1 [WHO:2] The Fourth Doctor\n")
      deck.export("xmage").warnings.should include(
        "Commander goes to the sideboard, as the format has no place to mark it",
      )
      deck.export("cockatrice").text.should include(%Q[<zone name="side">\n        <card number="1" name="The Fourth Doctor"])
    end

    it "csv says which section each card came from, so nothing moves" do
      sections = deck.export("csv").text.lines.drop(1).map{|line| line.split(",").first }.uniq
      sections.should eq(["Commander", "Main Deck", "Planar Deck", "Display Commander"])
      deck.export("csv").warnings.should eq([])
    end
  end

  # 4 foil and 4 nonfoil Islands of one printing are 8 Islands to any format
  # which cannot say which finish a card is
  describe "cards a format cannot tell apart" do
    let(:deck) { db.sets["mid"].deck_named("Innistrad: Midnight Hunt Bundle Land Pack") }

    it "merges them into one line" do
      deck.export("xmage").text.should include("8 [MID:381] Island\n")
      deck.export("cockatrice").text.should include(
        %Q[<card number="8" name="Island" setShortName="MID" collectorNumber="381"]
      )
      deck.export("mtgo").text.should include(%Q[Quantity="8" Sideboard="false" Name="Island"])
      deck.export("names").text.should include("8 Island\n")
    end

    it "leaves them alone where the finish can be written" do
      deck.export("text").text.should include("4 Island [MID:381]\n4 Island [MID:381] [foil]\n")
      deck.export("arena").text.should include("4 Island (MID) 381\n4 Island (MID) 381 *F*\n")
      deck.export("csv").text.should include("Main Deck,4,Island,MID,Innistrad: Midnight Hunt,381,Foil")
    end

    # Names is the one that merges across printings too, having nothing else
    # to tell them apart by
    it "merges different printings only where the printing is gone" do
      deck = DeckParser.new(db, "1 Island (MID) 270\n1 Island (MID) 271\n").deck
      deck.export("names").text.should eq("2 Island\n")
      deck.export("xmage").text.should eq("1 [MID:270] Island\n1 [MID:271] Island\n")
    end
  end

  describe "metadata" do
    let(:deck) { db.sets["jou"].deck_named("Wrath of the Mortals") }

    it "goes in as comments where a format has them" do
      deck.export("text").text.should start_with(<<~EOF)
      // NAME: Wrath of the Mortals - Journey into Nyx Event Deck
      // URL: http://mtg.wtf/deck/jou/wrath-of-the-mortals
      // DATE: 2014-05-23
      EOF
      deck.export("xmage").text.should start_with(<<~EOF)
      NAME: Wrath of the Mortals - Journey into Nyx Event Deck
      # URL: http://mtg.wtf/deck/jou/wrath-of-the-mortals
      # DATE: 2014-05-23
      EOF
      deck.export("cockatrice").text.should include(
        "<deckname>Wrath of the Mortals - Journey into Nyx Event Deck</deckname>"
      )
    end

    it "is missing from a deck someone pasted, and then no format writes it" do
      deck = DeckParser.new(db, "1 Sol Ring (C21) 263\n").deck
      deck.export("text").text.should eq("1 Sol Ring [C21:263]\n")
      deck.export("xmage").text.should eq("1 [C21:263] Sol Ring\n")
      deck.export("cockatrice").text.should include("<deckname></deckname>")
    end

    it "names the file after the deck" do
      deck.export("text").filename.should eq("Wrath of the Mortals.txt")
      deck.export("csv").filename.should eq("Wrath of the Mortals.csv")
      deck.export("xmage").filename.should eq("Wrath of the Mortals.dck")
      deck.export("mtgo").filename.should eq("Wrath of the Mortals.dek")
      deck.export("cockatrice").filename.should eq("Wrath of the Mortals.cod")
      DeckParser.new(db, "1 Sol Ring\n").deck.export("text").filename.should eq("deck.txt")
    end
  end

  # Cockatrice picks the printing from the uuid and nothing else: a card
  # without one falls back to whichever printing it prefers, which is not the
  # one we wrote in the set and number columns
  describe "cockatrice provider ids" do
    let(:decklist) { "1 Delver of Secrets (ISD) 51\n2 Fire // Ice (APC) 128\n" }

    it "writes a scryfall id for every card it knows" do
      deck.export("cockatrice").text.should include(
        %Q[<card number="1" name="Delver of Secrets" setShortName="ISD" collectorNumber="51" uuid="11bf83bb-c95b-4b4f-9a56-ce7a1816307a"/>],
        %Q[<card number="2" name="Fire // Ice" setShortName="APC" collectorNumber="128" uuid="f98f4538-5b5b-475d-b98f-49d01dae6f04"/>],
      )
    end

    it "is the only format which writes them" do
      %W[text names arena csv mtgo xmage].each do |format|
        deck.export(format).text.should_not include("11bf83bb")
      end
    end
  end

  describe "xml" do
    let(:decklist) { "1 R&D's Secret Lair (UNH) 135\n" }

    it "escapes what has to be escaped" do
      deck.export("cockatrice").text.should include(%Q[name="R&amp;D's Secret Lair"])
      deck.export("mtgo").text.should_not include("R&D")
    end
  end

  describe "MTGO ids" do
    it "falls back to another printing of the same card" do
      # j25 basics have no MTGO id of their own
      deck = DeckParser.new(db, "1 Swamp (J25) 87\n").deck
      deck.export("mtgo").text.should include(%Q[Quantity="1" Sideboard="false" Name="Swamp"])
      deck.export("mtgo").warnings.should eq([])
    end

    it "leaves out what MTGO does not have" do
      deck = DeckParser.new(db, "1 Sol Ring (C21) 263\n1 Zephyr Falcon (POR) 71\n").deck
      deck.export("mtgo").text.lines.grep(/Cards/).size.should eq(1)
      deck.export("mtgo").warnings.should eq(["Not on MTGO, so left out: Zephyr Falcon"])
    end
  end

  describe "the format list" do
    it "is what the dialog offers, in order" do
      DeckExporter.codes.should eq(["text", "names", "arena", "csv", "mtgo", "xmage", "cockatrice"])
      DeckExporter.all.map(&:name).should eq(
        ["Text", "Card names only", "Arena style", "CSV", "MTGO", "XMage", "Cockatrice"]
      )
    end

    it "raises for anything else" do
      deck = DeckParser.new(db, "1 Sol Ring\n").deck
      lambda { deck.export("mwdeck") }.should raise_error(/Unknown export format/)
    end
  end

  # The card names an xml export writes, in the order it writes them
  def names(xml)
    xml.scan(/<(?:card|Cards) [^>]*\b(?:name|Name)="([^"]*)"/).flatten
  end
end
