class ConditionIsCanopyland < Condition
  def search(db)
    names = [
      "fiery islet",
      "horizon canopy",
      "nurturing peatland",
      "silent clearing",
      "sunbaked canyon",
      "waterlogged grove",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:canopyland"
  end
end
