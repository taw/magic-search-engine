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

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a battleland"
  end
end
