class ConditionIsShadowland < Condition
  def search(db)
    names = [
      "choked estuary",
      "foreboding ruins",
      "fortified village",
      "game trail",
      "port town",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:shadowland"
  end
end
