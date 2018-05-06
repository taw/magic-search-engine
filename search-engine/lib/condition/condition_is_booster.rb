class ConditionIsBooster < ConditionSimple
  def match?(card)
    card.in_boosters?
  end

  def to_s
    "is:booster"
  end
end
