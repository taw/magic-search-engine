class ConditionIsAnte < Condition
  def search(db)
    names = [
      "amulet of quoz",
      "bronze tablet",
      "contract from below",
      "darkpact",
      "demonic attorney",
      "jeweled bird",
      "rebirth",
      "tempest efreet",
      "timmerian fiends",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:ante"
  end
end
