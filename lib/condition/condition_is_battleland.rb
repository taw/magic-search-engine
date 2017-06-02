class ConditionIsBattleland < Condition
  def search(db)
    names = [
      "prairie stream",
      "sunken hollow",
      "smoldering marsh",
      "cinder glade",
      "canopy vista",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:battleland"
  end
end
