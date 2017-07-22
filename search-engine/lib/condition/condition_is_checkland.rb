class ConditionIsCheckland < Condition
  def search(db)
    names = [
      "clifftop retreat",
      "dragonskull summit",
      "drowned catacomb",
      "glacial fortress",
      "hinterland harbor",
      "isolated chapel",
      "rootbound crag",
      "sulfur falls",
      "sunpetal grove",
      "woodland cemetery",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:checkland"
  end
end
