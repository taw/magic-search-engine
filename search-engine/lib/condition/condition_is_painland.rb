class ConditionIsPainland < Condition
  def search(db)
    names = [
      "adarkar wastes",
      "battlefield forge",
      "brushland",
      "caves of koilos",
      "karplusan forest",
      "llanowar wastes",
      "shivan reef",
      "sulfurous springs",
      "underground river",
      "yavimaya coast",
  ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:painland"
  end
end
