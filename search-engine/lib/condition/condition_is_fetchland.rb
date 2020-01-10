class ConditionIsFetchland < ConditionNickname
  def names
    [
      "arid mesa",
      "marsh flats",
      "misty rainforest",
      "scalding tarn",
      "verdant catacombs",
      "bloodstained mire",
      "flooded strand",
      "polluted delta",
      "windswept heath",
      "wooded foothills",
    ]
  end

  def to_s
    "is:fetchland"
  end
end
