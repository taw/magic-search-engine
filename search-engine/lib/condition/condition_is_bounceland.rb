class ConditionIsBounceland < ConditionNickname
  def names
    [
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
  end

  def to_s
    "is:bounceland"
  end
end
