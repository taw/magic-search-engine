class ConditionIsStorageland < ConditionNickname
  def names
    [
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
  end

  def to_s
    "is:storageland"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a storageland"
  end
end
