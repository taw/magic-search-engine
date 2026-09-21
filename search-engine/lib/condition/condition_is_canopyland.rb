class ConditionIsCanopyland < ConditionNickname
  def names
    [
      "fiery islet",
      "horizon canopy",
      "nurturing peatland",
      "silent clearing",
      "sunbaked canyon",
      "waterlogged grove",
    ]
  end

  def to_s
    "is:canopyland"
  end

  def explain
    "the card is a canopyland"
  end
end
