class ConditionIsSurveilland < ConditionNickname
  def names
    [
      "commercial district",
      "elegant parlor",
      "hedge maze",
      "lush portico",
      "meticulous archive",
      "raucous theater",
      "shadowy backstreet",
      "thundering falls",
      "undercity sewers",
      "underground mortuary",
    ]
  end

  def to_s
    "is:surveilland"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a surveil land"
  end
end
