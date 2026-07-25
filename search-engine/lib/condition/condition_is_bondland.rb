class ConditionIsBondland < ConditionNickname
  # 5 from Battlebond, 5 from Commander Legends, one for every color pair
  def names
    [
      "bountiful promenade",
      "luxury suite",
      "morphic pool",
      "rejuvenating springs",
      "sea of clouds",
      "spectator seating",
      "spire garden",
      "training center",
      "undergrowth stadium",
      "vault of champions",
    ]
  end

  def to_s
    "is:bondland"
  end
end
