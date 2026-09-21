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

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a canopyland"
  end
end
