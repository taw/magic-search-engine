describe PreconDeck do
  include_context "db"

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

  describe "#to_text_with_printings" do
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
      12 Mountain [THS:242]
      9 Island [THS:234]

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
      2 Plains [WHO:196]
      2 Island [WHO:198]
      3 Forest [WHO:204]

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
      1 The Fourth Doctor [WHO:193] [foil]
      EOF
    end

    it "works for normal decks" do
      deck = db.sets["jou"].deck_named("Wrath of the Mortals")
      deck.to_text_with_printings.should eq(deck_export_wrath_of_mortals)
    end

    it "handles extra sections" do
      deck = db.sets["who"].deck_named("Blast from the Past")
      deck.to_text_with_printings.should eq(deck_export_blast_from_the_past)
    end
  end
end
