class ConditionIsFastland < Condition
  def search(db)
    names = [
      "blackcleave cliffs",
      "blooming marsh",
      "botanical sanctum",
      "concealed courtyard",
      "copperline gorge",
      "darkslick shores",
      "inspiring vantage",
      "razorverge thicket",
      "seachrome coast",
      "spirebluff canal",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:fastland"
  end
end
