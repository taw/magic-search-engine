class ConditionIsFetchland < Condition
  def search(db)
    names = [
      "arid mesa",
      "marsh flats",
      "misty rainforest",
      "scalding tarn",
      "verdant catacombs",
      "bloodstained mire",
      "flooded strand",
      "polluted delta",
      "windswept heath",
      "wooded foothills",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:fetchland"
  end
end
