class ConditionIsAugment < ConditionSimple
  def match?(card)
    card.augment
  end

  def to_s
    "is:augment"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}one of the augment cards from Unstable"
  end
end
