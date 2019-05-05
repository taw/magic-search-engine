describe DeckParser do
  include_context "db"

  def physical_by_query(query, foil=false)
    printings = db.search(query).printings
    raise "Ambiguous query #{query.inspect}" if printings.size != 1
    PhysicalCard.for(printings[0], foil)
  end

  def physical_by_best(name, foil=false)
    printing = db.cards[name].printings.min_by(&:default_sort_index)
    raise "No such printing #{name}" unless printing
    PhysicalCard.for(printing, foil)
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

      sideboard
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
end
