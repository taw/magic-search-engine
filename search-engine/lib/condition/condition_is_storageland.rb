class ConditionIsStorageland < Condition
  def search(db)
    names = [
      "calciform pools",
      "crucible of the spirit dragon",
      "dreadship reef",
      "fountain of cho",
      "fungal reaches",
      "mage-ring network",
      "mercadian bazaar",
      "molten slagheap",
      "rushwood grove",
      "saltcrusted steppe",
      "saprazzan cove",
      "subterranean hangar",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:storageland"
  end
end
