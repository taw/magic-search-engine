class ConditionIsAugment < ConditionSimple
  def match?(card)
    card.augment
  end

  def to_s
    "is:augment"
  end
end
