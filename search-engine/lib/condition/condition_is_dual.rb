class ConditionIsDual < ConditionNickname
  def names
    [
      "badlands",
      "bayou",
      "plateau",
      "savannah",
      "scrubland",
      "taiga",
      "tropical island",
      "tundra",
      "underground sea",
      "volcanic island",
    ]
  end

  def to_s
    "is:dual"
  end
end
