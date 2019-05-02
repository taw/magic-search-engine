describe DeckParser do
  include_context "db"
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
      parser.main.should eq({"Lightning Bolt"=>40, "Mountain"=>20})
      parser.side.should eq({"Goblin Guide"=>15})
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
      Taiga
      10x Goblin Guide
      EOF
    end
    it do
      parser.main.should eq({"Lightning Bolt"=>40, "Mountain"=>20})
      parser.side.should eq({"Goblin Guide"=>10, "Taiga"=>1})
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

      sideboard
      2 Goblin Guide [ZEN] [foil]
      Goblin Guide [ZEN] [foil]
      EOF
    end
    it do
      parser.main.should eq({"Lightning Bolt"=>40})
      parser.side.should eq({"Goblin Guide"=>3})
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
    let(:lava_spike) { PhysicalCard.for db.cards["lava spike"].printings.min_by(&:default_sort_index) }
    let(:taiga) { PhysicalCard.for db.cards["taiga"].printings.min_by(&:default_sort_index) }
    let(:goblin_guide) { PhysicalCard.for db.cards["goblin guide"].printings.min_by(&:default_sort_index) }

    it do
      parser.main_cards.should eq [[40, lava_spike], [20, taiga]]
      parser.sideboard_cards.should eq [[15, goblin_guide]]
    end
  end

  describe "it deals with split cards" do
    # TODO
  end

  describe "it deals with unknown cards" do
    # TODO
  end
end
