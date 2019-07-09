class ConditionIsBounceland < Condition
  def search(db)
    names = [
      "azorius chancery",
      "boros garrison",
      "coral atoll",
      "dimir aqueduct",
      "dormant volcano",
      "everglades",
      "golgari rot farm",
      "gruul turf",
      "izzet boilerworks",
      "jungle basin",
      "karoo",
      "orzhov basilica",
      "rakdos carnarium",
      "selesnya sanctuary",
      "simic growth chamber",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:bounceland"
  end
end
