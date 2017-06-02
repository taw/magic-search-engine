class ConditionIsFilterland < Condition
  def search(db)
    names = [
      "skycloud expanse",
      "darkwater catacombs",
      "shadowblood ridge",
      "mossfire valley",
      "sungrass prairie",
      "mystic gate",
      "sunken ruins",
      "graven cairns",
      "fire-lit thicket",
      "wooded bastion",
      "fetid heath",
      "cascade bluffs",
      "twilight mire",
      "rugged prairie",
      "flooded grove"
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
