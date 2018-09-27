class ConditionIsGuildgate < Condition
  def search(db)
    names = [
      "azorius guildgate",
      "dimir guildgate",
      "rakdos guildgate",
      "gruul guildgate",
      "selesnya guildgate",
      "orzhov guildgate",
      "izzet guildgate",
      "golgari guildgate",
      "boros guildgate",
      "simic guildgate",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:guildgate"
  end
end
