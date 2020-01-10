class ConditionIsFastland < ConditionNickname
  def names
    [
      "blackcleave cliffs",
      "blooming marsh",
      "botanical sanctum",
      "concealed courtyard",
      "copperline gorge",
      "darkslick shores",
      "inspiring vantage",
      "razorverge thicket",
      "seachrome coast",
      "spirebluff canal",
    ]
  end

  def to_s
    "is:fastland"
  end
end
