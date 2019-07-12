class ConditionIsTriland < Condition
  def search(db)
    names = [
      "arcane sanctum",
      "crumbling necropolis",
      "frontier bivouac",
      "jungle shrine",
      "mystic monastery",
      "nomad outpost",
      "opulent palace",
      "sandsteppe citadel",
      "savage lands",
      "seaside citadel",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:triland"
  end
end
