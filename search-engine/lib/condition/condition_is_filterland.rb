class ConditionIsFilterland < Condition
  def search(db)
    names = [
      "cascade bluffs",
      "cascading cataracts",
      "crystal quarry",
      "darkwater catacombs",
      "fetid heath",
      "fire-lit thicket",
      "flooded grove",
      "graven cairns",
      "mossfire valley",
      "mystic gate",
      "rugged prairie",
      "shadowblood ridge",
      "skycloud expanse",
      "sungrass prairie",
      "sunken ruins",
      "twilight mire",
      "wooded bastion",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:filterland"
  end
end
