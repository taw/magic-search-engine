class ConditionIsPainland < ConditionNickname
  def names
    [
      "adarkar wastes",
      "battlefield forge",
      "brushland",
      "caves of koilos",
      "karplusan forest",
      "llanowar wastes",
      "shivan reef",
      "sulfurous springs",
      "underground river",
      "yavimaya coast",
    ]
  end

  def to_s
    "is:painland"
  end
end
