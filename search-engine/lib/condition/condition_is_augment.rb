class ConditionIsAugment < ConditionSimple
  def match?(card)
    card.augment
  end

  def to_s
    "is:augment"
  end

  def explain
    "the card is one of the augment cards from Unstable"
  end
end
