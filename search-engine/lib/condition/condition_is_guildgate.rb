class ConditionIsGuildgate < ConditionNickname
  def names
    [
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
  end

  def to_s
    "is:guildgate"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a guildgate"
  end
end
