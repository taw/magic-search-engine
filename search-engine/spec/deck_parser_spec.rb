describe DeckParser do
  include_context "db"

  def physical_by_query(query, foil=false, etched=false)
    printings = db.search(query).printings
    raise "Ambiguous query #{query.inspect}" if printings.size != 1
    PhysicalCard.for(printings[0], foil: foil, etched: etched)
  end

  def physical_by_best(name, foil=false, etched=false)
    printing = db.cards[name].printings.min_by(&:default_sort_index)
    raise "No such printing #{name}" unless printing
    PhysicalCard.for(printing, foil: foil, etched: etched)
  end

  let(:parser) { DeckParser.new(db, text) }
  let(:deck) { parser.deck }
  let(:main_cards) { parser.main_cards }
  let(:sideboard_cards) { parser.sideboard_cards }

  describe "simple deck" do
    let(:text) do
      <<~EOF
      40 Lightning Bolt
      20 Mountain

      Sideboard
      15 Goblin Guide
      EOF
    end
    it do
      parser.main.should eq([
        {name: "Lightning Bolt", count: 40},
        {name: "Mountain", count: 20},
      ])
      parser.side.should eq([
        {name: "Goblin Guide", count: 15},
      ])
    end
  end

  describe "syntax variation" do
    let(:text) do
      <<~EOF
      // Amazing deck
      30x Lightning Bolt
      10  Lightning Bolt
      # Do we need more mountains?
      20x Mountain

      sideboard:
        # try this
      Taiga
        // and that
      10x Goblin Guide
      EOF
    end
    it do
      parser.main.should eq([
        {name: "Lightning Bolt", count: 30},
        {name: "Lightning Bolt", count: 10},
        {name: "Mountain", count: 20},
      ])
      parser.side.should eq([
        {name: "Taiga", count: 1},
        {name: "Goblin Guide", count: 10},
      ])
    end
  end

  describe "SB:" do
    let(:text) do
      <<~EOF
      // Amazing deck
      30x Lightning Bolt
      10  Lightning Bolt
      SB: Taiga
      SB: 10x Goblin Guide
      20x Mountain
      EOF
    end
    it do
      parser.main.should eq([
        {name: "Lightning Bolt", count: 30},
        {name: "Lightning Bolt", count: 10},
        {name: "Mountain", count: 20},
      ])
      parser.side.should eq([
        {name: "Taiga", count: 1},
        {name: "Goblin Guide", count: 10},
      ])
    end
  end

  # Add it in the future?
  describe "it ignores annotations" do
    let(:text) do
      <<~EOF
      10x Lightning Bolt [M10]
      10x Lightning Bolt [4ed/208]
      10x Lightning Bolt [foil]
      10x Lightning Bolt [M11] [foil]
      10x A25 Lightning Bolt
      10x A25 Lightning Bolt [foil]
      10x Lightning Bolt [A25:141]
      10x Lightning Bolt [A25/141] [foil]

      sideboard
      2 Goblin Guide [ZEN] [foil]
      Goblin Guide [ZEN] [foil]
      EOF
    end
    it do
      parser.main.should eq([
        {name: "Lightning Bolt", count: 10, set_code: "M10"},
        {name: "Lightning Bolt", count: 10, set_code: "4ed", number: "208"},
        {name: "Lightning Bolt", count: 10, foil: true},
        {name: "Lightning Bolt", count: 10, set_code: "M11", foil: true},
        {name: "A25 Lightning Bolt", count: 10}, # FIXME
        {name: "A25 Lightning Bolt", count: 10, foil: true}, # FIXME
        {name: "Lightning Bolt", count: 10, set_code: "A25", number: "141"},
        {name: "Lightning Bolt", count: 10, set_code: "A25", number: "141", foil: true},
      ])
      parser.side.should eq([
        {name: "Goblin Guide", count: 2, set_code: "ZEN", foil: true},
        {name: "Goblin Guide", count: 1, set_code: "ZEN", foil: true},
      ])
    end
  end

  describe "it picks latest card by default" do
    let(:text) do
      <<~EOF
      40 Lava Spike
      20 Taiga

      Sideboard
      15 Goblin Guide
      EOF
    end
    let(:lava_spike) { physical_by_best("lava spike") }
    let(:taiga) { physical_by_best("taiga") }
    let(:goblin_guide) { physical_by_best("goblin guide") }

    it do
      parser.main_cards.should eq [[40, lava_spike], [20, taiga]]
      parser.sideboard_cards.should eq [[15, goblin_guide]]
    end
  end

  describe "it deals with split cards" do
    let(:text) do
      <<~EOF
      4 Fire // Ice
      4 Delver of Secrets
      4 Awoken Horror
      4 Assemble
      EOF
    end
    let(:fire_ice) { physical_by_best("fire") }
    let(:delver_of_secrets) { physical_by_best("delver of secrets") }
    let(:thing_in_the_ice) { physical_by_best("thing in the ice") }
    let(:assure_assemble) { physical_by_best("assure") }

    it do
      parser.main_cards.should eq([
        [4, fire_ice],
        [4, delver_of_secrets],
        [4, thing_in_the_ice],
        [4, assure_assemble],
      ])
    end
  end

  describe "it deals with unknown cards" do
    let(:text) do
      <<~EOF
      1 Lightning Bolt
      2 Blue-Eyes White Dragon
      3 Pod of Greed
      4 Mountain
      EOF
    end

    let(:lightning_bolt) { physical_by_best("lightning bolt") }
    let(:blue_eyes_white_dragon) { UnknownCard.new("Blue-Eyes White Dragon") }
    let(:pod_of_greed) { UnknownCard.new("Pod of Greed") }
    let(:mountain) { physical_by_best("mountain") }

    it do
      parser.main_cards.should eq([
        [1, lightning_bolt],
        [2, blue_eyes_white_dragon],
        [3, pod_of_greed],
        [4, mountain],
      ])
    end
  end

  describe "if tag is foil, card is foil (regardless of such foil existing or not)" do
    let(:text) do
      <<~EOF
      1 Tezzeret, Master of the Bridge
      2 Tezzeret, Master of the Bridge [foil]
      3 Black Lotus
      4 Black Lotus [foil]
      5 Pod of Greed
      6 Pod of Greed [foil]
      EOF
    end

    it do
      parser.main_cards.should eq([
        [1, physical_by_best("tezzeret, master of the bridge") ],
        [2, physical_by_best("tezzeret, master of the bridge", true) ],
        [3, physical_by_best("black lotus") ],
        [4, physical_by_best("black lotus", true) ],
        [11, UnknownCard.new("Pod of Greed")],
      ])
    end
  end

  describe "it resolves to specified set, or best available set" do
    let(:text) do
      <<~EOF
      1 Birds of Paradise [LEA]
      # Check aliases
      2 Birds of Paradise [4e]
      3 Birds of Paradise [5ed]
      4 Black Lotus [m10]
      5 Black Lotus [lea]
      6 Black Lotus [2ed]
      EOF
    end

    it do
      parser.main_cards.should eq([
        [1, physical_by_query("birds of paradise e:lea")],
        [2, physical_by_query("birds of paradise e:4e")],
        [3, physical_by_query("birds of paradise e:5e")],
        [10, physical_by_query("black lotus e:2ed")],
        [5, physical_by_query("black lotus e:lea")],
      ])
    end
  end

  describe "it resolves number if possible" do
    let(:text) do
      <<~EOF
      1 Brothers Yamazaki [CHK/160a]
      2 Brothers Yamazaki [CHK/160B]
      3 Ice // Fire [UMA:225]
      # This is correct number is wrong set, testing that set takes precedence
      4 Birds of Paradise [M10/165]
      EOF
    end

    let(:brother_a) { physical_by_query("brothers yamazaki number=160a") }
    let(:brother_b) { physical_by_query("brothers yamazaki number=160b") }
    let(:ice_fire) { physical_by_query("fire e:uma number=225a") }
    let(:birds_m10) { physical_by_query("birds of paradise e:m10 number=168") }

    it do
      parser.main_cards.should eq([
        [1, brother_a],
        [2, brother_b],
        [3, ice_fire],
        [4, birds_m10],
      ])
    end
  end

  describe "it knows every section we export" do
    let(:text) do
      <<~EOF
      // NAME: Not A Real Deck - Some Set Commander Deck
      COMMANDER: 1 Kydele, Chosen of Kruphix
      40 Lightning Bolt

      Sideboard
      15 Goblin Guide

      Planar Deck
      1 Naya

      Scheme Deck
      2 All in Good Time

      Display Commander
      1 Ghave, Guru of Spores
      EOF
    end

    it do
      parser.sections.should eq({
        "Main Deck" => [{name: "Lightning Bolt", count: 40}],
        "Commander" => [{name: "Kydele, Chosen of Kruphix", count: 1}],
        "Sideboard" => [{name: "Goblin Guide", count: 15}],
        "Planar Deck" => [{name: "Naya", count: 1}],
        "Scheme Deck" => [{name: "All in Good Time", count: 2}],
        "Display Commander" => [{name: "Ghave, Guru of Spores", count: 1}],
      })
      deck.section("Planar Deck").should eq([[1, physical_by_best("naya")]])
      deck.section("Scheme Deck").should eq([[2, physical_by_best("all in good time")]])
      deck.section("Display Commander").should eq([[1, physical_by_best("ghave, guru of spores")]])
    end
  end

  describe "section header variations" do
    let(:text) do
      <<~EOF
      Deck
      40 Lightning Bolt

      Sideboard: 15
      15 Goblin Guide

      COMMANDER:
      1 Kydele, Chosen of Kruphix
      EOF
    end

    it do
      parser.main.should eq([{name: "Lightning Bolt", count: 40}])
      parser.side.should eq([{name: "Goblin Guide", count: 15}])
      parser.commander.should eq([{name: "Kydele, Chosen of Kruphix", count: 1}])
    end
  end

  describe "etched" do
    let(:text) do
      <<~EOF
      1 Kardur, Doomscourge
      2 Kardur, Doomscourge [foil]
      3 Kardur, Doomscourge [foil] [etched]
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Kardur, Doomscourge", count: 1},
        {name: "Kardur, Doomscourge", count: 2, foil: true},
        {name: "Kardur, Doomscourge", count: 3, foil: true, etched: true},
      ])
      parser.main_cards.should eq([
        [1, physical_by_best("kardur, doomscourge")],
        [2, physical_by_best("kardur, doomscourge", true)],
        [3, physical_by_best("kardur, doomscourge", true, true)],
      ])
    end
  end

  describe "arena format" do
    let(:text) do
      <<~EOF
      About
      Name Death & Taxes

      Companion
      1 Yorion, Sky Nomad (IKO) 232

      Deck
      2 Arid Mesa (MH2) 244
      4 Swords to Plowshares (STA) 8
      1 Lightning Bolt (A25) 141

      Sideboard
      2 Containment Priest (M21) 13
      1 Yorion, Sky Nomad (IKO) 232
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Arid Mesa", count: 2, set_code: "MH2", number: "244"},
        {name: "Swords to Plowshares", count: 4, set_code: "STA", number: "8"},
        {name: "Lightning Bolt", count: 1, set_code: "A25", number: "141"},
      ])
      # Arena lists its companion twice, we only want it once
      parser.side.should eq([
        {name: "Containment Priest", count: 2, set_code: "M21", number: "13"},
        {name: "Yorion, Sky Nomad", count: 1, set_code: "IKO", number: "232"},
      ])
      # Arena numbers cards its own way, and a number we don't have just falls
      # back to the best printing in the set it asked for
      parser.main_cards.should eq([
        [2, physical_by_query("arid mesa e:mh2 number=244")],
        [4, physical_by_query("swords to plowshares e:sta number=10")],
        [1, physical_by_query("lightning bolt e:a25")],
      ])
    end
  end

  # Arena has one code per Arena year for every Alchemy set of that year, so
  # (Y22) is ymid, yneo and ysnc at once and its numbers collide - all three
  # start at 1. The name is what picks the card; the code and number only pick
  # the printing, exactly as they do for a real set.
  describe "Arena's Alchemy year codes" do
    let(:text) do
      <<~EOF
      Deck
      1 Big Spender (Y22) 10
      1 Goblin Morale Sergeant (Y23) 14
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Big Spender", count: 1, set_code: "Y22", number: "10"},
        {name: "Goblin Morale Sergeant", count: 1, set_code: "Y23", number: "14"},
      ])
      parser.main_cards.should eq([
        [1, physical_by_query("big spender e:ysnc number=10")],
        [1, physical_by_query("goblin morale sergeant e:ydmu number=14")],
      ])
    end
  end

  describe "companion not repeated in the sideboard" do
    let(:text) do
      <<~EOF
      Companion
      1 Yorion, Sky Nomad (IKO) 232

      Deck
      1 Arid Mesa (MH2) 244

      Sideboard
      2 Containment Priest (M21) 13
      EOF
    end

    it do
      parser.side.should eq([
        {name: "Containment Priest", count: 2, set_code: "M21", number: "13"},
        {name: "Yorion, Sky Nomad", count: 1, set_code: "IKO", number: "232"},
      ])
    end
  end

  describe "other programs writing arena-style lines" do
    let(:text) do
      <<~EOF
      4 Counterspell (CMR) 632 *F* #TargetedDisruption
      1 Ashnod's Altar (ema) 218 *F* [Mana Advantage]
      1 Amulet of Vigor (plst) WWK-121 *F* [Ramp]
      1x Lightning Bolt (A25) 141 *E*
      1 Goblin Guide (ZEN) 125 *CMDR*
      1x Black Lotus (LEA)
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Counterspell", count: 4, set_code: "CMR", number: "632", foil: true},
        {name: "Ashnod's Altar", count: 1, set_code: "ema", number: "218", foil: true},
        {name: "Amulet of Vigor", count: 1, set_code: "plst", number: "WWK-121", foil: true},
        {name: "Lightning Bolt", count: 1, set_code: "A25", number: "141", etched: true},
        {name: "Goblin Guide", count: 1, set_code: "ZEN", number: "125"},
        {name: "Black Lotus", count: 1, set_code: "LEA"},
      ])
      parser.main_cards.should eq([
        [4, physical_by_query("counterspell e:cmr number=632", true)],
        [1, physical_by_query("ashnod's altar e:ema", true)],
        [1, physical_by_query("amulet of vigor e:plst", true)],
        [1, PhysicalCard.for(db.cards["lightning bolt"].printings.find{|c| c.set_code == "a25"}, finish: :etched)],
        [1, physical_by_query("goblin guide e:zen")],
        [1, physical_by_query("black lotus e:lea")],
      ])
    end
  end

  # Archidekt leaves the set code out for cards Arena doesn't have
  describe "arena-style line with no set code" do
    let(:text) do
      <<~EOF
      3 Think Twice () 92
      1 Ashnod's Altar ()
      2 Counterspell () 92 *F* [Mana Advantage]
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Think Twice", count: 3},
        {name: "Ashnod's Altar", count: 1},
        {name: "Counterspell", count: 2, foil: true},
      ])
      parser.main_cards.should eq([
        [3, physical_by_best("think twice")],
        [1, physical_by_best("ashnod's altar")],
        [2, physical_by_best("counterspell", true)],
      ])
    end
  end

  # Battle the Horde ships with "Unquenchable Fury (TBTH)", so this is not just
  # about playtest cards - our own export has to survive it
  describe "a card name that ends with something shaped like a set code" do
    let(:text) do
      <<~EOF
      1 Unquenchable Fury (TBTH)
      2 Bind (CMB1)
      # Only a name we don't know is read as a printing
      3 Sol Ring (C21)
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Unquenchable Fury (TBTH)", count: 1},
        {name: "Bind (CMB1)", count: 2},
        {name: "Sol Ring", count: 3, set_code: "C21"},
      ])
      parser.main_cards.should eq([
        [1, physical_by_best("unquenchable fury (tbth)")],
        [2, physical_by_best("bind (cmb1)")],
        [3, physical_by_query("sol ring e:c21")],
      ])
    end
  end

  # MythicHub rules its section headers off, puts the number after a hash, and
  # spells the finish out instead of marking it
  describe "mythichub format" do
    let(:text) do
      <<~EOF
      == COMMANDER ==
      1 Kitsa, Otterball Elite [BLB] #54

      == MAINBOARD ==
      1 Delver of Secrets [ISD] #51
      1 Talisman of Progress [SLD] #1052 etched
      1 Sol Ring [C21] #263 foil
      1 Amulet of Vigor [PLST] #WWK-121
      1 Foil [UMA] #55

      == SIDEBOARD ==
      1 Naturalize [M10] #195
      EOF
    end

    it do
      parser.commander.should eq([
        {name: "Kitsa, Otterball Elite", count: 1, set_code: "BLB", number: "54"},
      ])
      parser.main.should eq([
        {name: "Delver of Secrets", count: 1, set_code: "ISD", number: "51"},
        {name: "Talisman of Progress", count: 1, set_code: "SLD", number: "1052", etched: true},
        {name: "Sol Ring", count: 1, set_code: "C21", number: "263", foil: true},
        {name: "Amulet of Vigor", count: 1, set_code: "PLST", number: "WWK-121"},
        {name: "Foil", count: 1, set_code: "UMA", number: "55"},
      ])
      parser.side.should eq([
        {name: "Naturalize", count: 1, set_code: "M10", number: "195"},
      ])
      # Its numbers are physical cards, ours are faces, so 51 finds 51a
      parser.main_cards.should eq([
        [1, physical_by_query("delver of secrets e:isd")],
        [1, physical_by_query("talisman of progress e:sld", true, true)],
        [1, physical_by_query("sol ring e:c21", true)],
        [1, physical_by_query("amulet of vigor e:plst")],
        [1, physical_by_query("foil e:uma")],
      ])
    end
  end

  # Moxfield's tags start with a hash too, and are not collector numbers
  describe "hash tags are not collector numbers" do
    let(:text) do
      <<~EOF
      4 Counterspell (CMR) 632 #TargetedDisruption
      1 Sol Ring [C21] #263 #!Collection
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Counterspell", count: 4, set_code: "CMR", number: "632"},
        {name: "Sol Ring", count: 1, set_code: "C21"},
      ])
    end
  end

  # XMage writes its own metadata above the cards, and none of it is a card
  describe "xmage format" do
    let(:text) do
      <<~EOF
      NAME: Wrath of the Mortals
      AUTHOR: Wizards of the Coast
      # URL: http://mtg.wtf/deck/jou/wrath-of-the-mortals
      LAYOUT MAIN:(1,1)(A)|
      1 [ISD:51] Delver of Secrets
      40 [A25:141] Lightning Bolt
      SB: 15 [ZEN:125] Goblin Guide
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Delver of Secrets", count: 1, set_code: "ISD", number: "51"},
        {name: "Lightning Bolt", count: 40, set_code: "A25", number: "141"},
      ])
      parser.side.should eq([
        {name: "Goblin Guide", count: 15, set_code: "ZEN", number: "125"},
      ])
    end
  end

  # The CSV export has a column for the section, so nothing here has to be
  # guessed from where a card is in the file
  describe "csv format" do
    let(:text) do
      <<~EOF
      Section,Count,Name,Set code,Set name,Collector number,Finish
      Commander,1,"Kydele, Chosen of Kruphix",C16,Commander 2016,35,Foil
      Main Deck,40,Lightning Bolt,A25,Masters 25,141,Normal
      Main Deck,1,Delver of Secrets,ISD,Innistrad,51,Normal
      Main Deck,1,Talisman of Progress,SLD,Secret Lair Drop Series,1052,Etched
      Sideboard,15,Goblin Guide,ZEN,Zendikar,125,Normal
      Planar Deck,1,Naya,OHOP,Planechase,27,Normal
      EOF
    end

    it do
      parser.sections.should eq({
        "Main Deck" => [
          {name: "Lightning Bolt", count: 40, set_code: "A25", number: "141"},
          {name: "Delver of Secrets", count: 1, set_code: "ISD", number: "51"},
          {name: "Talisman of Progress", count: 1, set_code: "SLD", number: "1052", etched: true},
        ],
        "Commander" => [{name: "Kydele, Chosen of Kruphix", count: 1, set_code: "C16", number: "35", foil: true}],
        "Sideboard" => [{name: "Goblin Guide", count: 15, set_code: "ZEN", number: "125"}],
        "Planar Deck" => [{name: "Naya", count: 1, set_code: "OHOP", number: "27"}],
        "Scheme Deck" => [],
        "Display Commander" => [],
      })
      parser.commander_cards.should eq([[1, physical_by_query("kydele, chosen of kruphix e:c16", true)]])
      parser.main_cards.should eq([
        [40, physical_by_query("lightning bolt e:a25")],
        [1, physical_by_query("delver of secrets e:isd")],
        [1, physical_by_query("talisman of progress e:sld", true, true)],
      ])
    end
  end

  # Every collection site exports the same table under its own column names,
  # and the ones we have no use for are ignored rather than rejected
  describe "csv from somewhere else" do
    let(:text) do
      <<~EOF
      "Count","Tradelist Count","Name","Edition","Condition","Foil","Collector Number"
      "4","0","Lightning Bolt","a25","Near Mint","","141"
      "1","0","Sol Ring","c21","Near Mint","foil","263"
      "1","0","Talisman of Progress","sld","Near Mint","etched","1052"
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Lightning Bolt", count: 4, set_code: "a25", number: "141"},
        {name: "Sol Ring", count: 1, set_code: "c21", number: "263", foil: true},
        {name: "Talisman of Progress", count: 1, set_code: "sld", number: "1052", etched: true},
      ])
    end
  end

  # A decklist has commas in it, so a table is only a table when the first row
  # says which columns it has
  describe "a decklist with commas in it is not a csv" do
    let(:text) do
      <<~EOF
      1 Bruna, the Fading Light
      1 Kydele, Chosen of Kruphix
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Bruna, the Fading Light", count: 1},
        {name: "Kydele, Chosen of Kruphix", count: 1},
      ])
    end
  end

  # The two formats which are XML. UserDeckPreprocessor does this for a file
  # someone uploaded; this is the same file pasted into the box.
  describe "cockatrice .cod pasted in" do
    let(:text) do
      <<~EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <cockatrice_deck version="1">
          <deckname>Not A Real Deck</deckname>
          <comments></comments>
          <zone name="main">
              <card number="1" name="Delver of Secrets" setShortName="ISD" collectorNumber="51" uuid="11bf83bb-c95b-4b4f-9a56-ce7a1816307a"/>
              <card number="40" name="Lightning Bolt" setShortName="A25" collectorNumber="141" uuid="a1b2c3d4-0000-0000-0000-000000000000"/>
          </zone>
          <zone name="side">
              <card number="15" name="Goblin Guide" setShortName="ZEN" collectorNumber="125"/>
          </zone>
      </cockatrice_deck>
      EOF
    end

    it do
      parser.main_cards.should eq([
        [1, physical_by_query("delver of secrets e:isd")],
        [40, physical_by_query("lightning bolt e:a25")],
      ])
      parser.sideboard_cards.should eq([[15, physical_by_query("goblin guide e:zen")]])
    end
  end

  describe "mtgo .dek pasted in" do
    let(:text) do
      <<~EOF
      <?xml version="1.0" encoding="utf-8"?>
      <Deck xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <NetDeckID>0</NetDeckID>
        <PreconstructedDeckID>0</PreconstructedDeckID>
        <Cards CatID="50572" Quantity="40" Sideboard="false" Name="Lightning Bolt" />
        <Cards CatID="42466" Quantity="15" Sideboard="true" Name="Goblin Guide" />
      </Deck>
      EOF
    end

    # A .dek has no set codes in it at all, so all it can say is the name
    it do
      parser.main_cards.should eq([[40, physical_by_best("lightning bolt")]])
      parser.sideboard_cards.should eq([[15, physical_by_best("goblin guide")]])
    end
  end

  # World Championship decks number a card with the player's initials, and the
  # decks we ship are full of them
  describe "collector numbers that are not just a number" do
    let(:text) do
      <<~EOF
      4 Fire // Ice (WC01) jt128
      3 Fire // Ice [WC02:shh128]
      2 Brushland [PTC] #et352
      1 Nezumi Graverobber (PSAL) A39
      EOF
    end

    it do
      parser.main.should eq([
        {name: "Fire // Ice", count: 4, set_code: "WC01", number: "jt128"},
        {name: "Fire // Ice", count: 3, set_code: "WC02", number: "shh128"},
        {name: "Brushland", count: 2, set_code: "PTC", number: "et352"},
        {name: "Nezumi Graverobber", count: 1, set_code: "PSAL", number: "A39"},
      ])
      # We number the faces, everyone else numbers the physical card, so jt128
      # has to find jt128a rather than falling back to whatever is numbered 128
      parser.main_cards.should eq([
        [4, physical_by_query("fire e:wc01 number=jt128a")],
        [3, physical_by_query("fire e:wc02 number=shh128a")],
        [2, physical_by_query("brushland e:ptc number=et352")],
        [1, physical_by_query("nezumi graverobber e:psal number=A39a")],
      ])
    end
  end

  # Whatever we hand out has to be something we can take back
  describe "it parses back every deck we export" do
    def count_cards(cards)
      counts = Hash.new(0)
      cards.each{|count, card| counts[yield(card)] += count }
      counts
    end

    def cards_by_printing(deck)
      DeckParser::SECTIONS.to_h{|name| [name, count_cards(deck.section(name)){|card| card }] }
    end

    def cards_by_name(deck)
      DeckParser::SECTIONS.to_h{|name| [name, count_cards(deck.section(name)){|card| card.name }] }
    end

    let(:decks) { db.sets.values.flat_map(&:decks) }
    # Three of the decks we ship are tokens only, and an export with no cards in
    # it has nothing to round trip
    let(:decks_with_cards) { decks.reject{|deck| deck.number_of_total_cards.zero? } }

    it "card names only export round trips" do
      # Without printings all we can round trip is names
      mismatched = decks.reject do |deck|
        cards_by_name(DeckParser.new(db, deck.export("names").text).deck) == cards_by_name(deck)
      end
      mismatched.should eq([])
    end

    it "text export round trips" do
      mismatched = decks.reject do |deck|
        cards_by_printing(DeckParser.new(db, deck.export("text").text).deck) == cards_by_printing(deck)
      end
      mismatched.should eq([])
    end

    # The metadata comments belong to a precon, and what we read back is a
    # decklist rather than one
    def strip_metadata(text, code)
      case code
      when "xmage" then text.lines.reject{|line| line =~ /\A(#|NAME:)/ }.join
      when "cockatrice" then text.sub(%r[ *<comments>.*?</comments>\n]m, "").sub(%r[ *<deckname>.*</deckname>\n], "")
      else text
      end
    end

    # Every other format says less than ours does - some cannot mark a finish,
    # none of them has every section - so what has to survive is what the format
    # itself wrote. What it left out is already missing from the file we compare
    # against, which is what makes one comparison do for all of them.
    def round_trips?(deck, code)
      export = deck.export(code).text
      strip_metadata(DeckParser.new(db, export).deck.export(code).text, code) == strip_metadata(export, code)
    end

    %W[arena arena_compatible csv mythichub xmage].each do |code|
      it "#{code} export round trips" do
        decks_with_cards.reject{|deck| round_trips?(deck, code) }.should eq([])
      end
    end

    # One pass over index/scryfall_ids.txt per export, so this one takes a
    # sample of the decks rather than all three thousand
    it "cockatrice export round trips" do
      sample = decks_with_cards.each_slice(60).map(&:first)
      sample.reject{|deck| round_trips?(deck, "cockatrice") }.should eq([])
    end

    # An .dek names no set and no number, so the printing a card comes back on
    # is whichever one we would have picked ourselves
    it "mtgo export round trips by name" do
      sample = decks_with_cards.each_slice(60).map(&:first)
      mismatched = sample.reject do |deck|
        export = deck.export("mtgo")
        # Cards MTGO does not have are not in the file to be read back
        next true if export.warnings.any?
        parsed = DeckParser.new(db, export.text).deck
        counts = Hash.new(0)
        deck.all_cards.each{|count, card| counts[card.name] += count }
        parsed.all_cards.each{|count, card| counts[card.name] -= count }
        counts.values.all?(&:zero?)
      end
      mismatched.should eq([])
    end
  end
end
