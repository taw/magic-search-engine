# Decklists (both precons and the deck visualizer) group cards by type
describe "#type_group" do
  include_context "db", "mrd", "nph", "fut", "cns", "ohop"

  def type_group(query)
    printings = db.search(query).printings
    raise "No card matching #{query.inspect}" if printings.empty?
    printings[0].type_group
  end

  it "groups by the card's type" do
    type_group("!Auriok Bladewarden").should eq [1, "Creature"]
    type_group("!Karn Liberated").should eq [2, "Planeswalker"]
    type_group("!Altar's Light").should eq [3, "Instant"]
    type_group("!Barter in Blood").should eq [4, "Sorcery"]
    type_group("!Aether Spellbomb").should eq [5, "Artifact"]
    type_group("!Arrest").should eq [6, "Enchantment"]
    type_group("!Blinkmoth Well").should eq [7, "Land"]
  end

  it "files a card with more than one type under the most specific one" do
    # Artifact lands are lands, artifact creatures are creatures,
    # and Dryad Arbor is a creature even though it's also a land
    type_group("!Ancient Den").should eq [7, "Land"]
    type_group("!Bosh, Iron Golem").should eq [1, "Creature"]
    type_group("!Dryad Arbor").should eq [1, "Creature"]
  end

  it "has a bucket for cards which are none of these" do
    type_group("e:cns t:conspiracy is:specialformat").should eq [8, "Other"]
    type_group("e:ohop t:plane is:specialformat").should eq [8, "Other"]
  end

  it "sorts cards we know nothing about last" do
    UnknownCard.new("Pod of Greed").type_group.should eq [9, "Other"]
    UnknownCard::TYPE_GROUP[0].should be > Card::OTHER_TYPE_GROUP[0]
  end

  it "is available on every kind of card object" do
    printing = db.search("!Bosh, Iron Golem").printings[0]
    printing.type_group.should eq [1, "Creature"]
    printing.card.type_group.should eq [1, "Creature"]
    PhysicalCard.for(printing).type_group.should eq [1, "Creature"]
  end
end
