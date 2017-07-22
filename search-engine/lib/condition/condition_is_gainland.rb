class ConditionIsGainland < Condition
  def search(db)
    names = [
      "akoum refuge",
      "bloodfell caves",
      "blossoming sands",
      "dismal backwater",
      "graypelt refuge",
      "jungle hollow",
      "jwar isle refuge",
      "kazandu refuge",
      "rugged highlands",
      "scoured barrens",
      "sejiri refuge",
      "swiftwater cliffs",
      "thornwood falls",
      "tranquil cove",
      "wind-scarred crag",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:gainland"
  end
end
