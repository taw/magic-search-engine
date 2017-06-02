class ConditionIsDual < Condition
  def search(db)
    names = [
      "badlands",
      "bayou",
      "plateau",
      "savannah",
      "scrubland",
      "taiga",
      "tropical island",
      "tundra",
      "underground sea",
      "volcanic island",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:dual"
  end
end
