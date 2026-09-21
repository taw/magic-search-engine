class ConditionIsPower9 < ConditionNickname
  def names
    [
      "ancestral recall",
      "black lotus",
      "mox emerald",
      "mox jet",
      "mox pearl",
      "mox ruby",
      "mox sapphire",
      "time walk",
      "timetwister",
    ]
  end

  def to_s
    "is:power9"
  end

  def explain
    "the card is one of the Power Nine"
  end
end
