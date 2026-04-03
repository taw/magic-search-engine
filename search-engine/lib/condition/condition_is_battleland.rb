class ConditionIsBattleland < ConditionNickname
  def names
    [
      "canopy vista",
      "cinder glade",
      "eclipsed steppe",
      "prairie stream",
      "radiant summit",
      "scorched geyser",
      "smoldering marsh",
      "sodden verdure",
      "sunken hollow",
      "vernal fen",
    ]
  end

  def to_s
    "is:battleland"
  end
end
