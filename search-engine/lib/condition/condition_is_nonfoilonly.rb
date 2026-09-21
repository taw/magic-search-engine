class ConditionIsNonfoilonly < ConditionSimple
  def match?(card)
    card.nonfoilonly?
  end

  def to_s
    "is:nonfoilonly"
  end

  def explain(negated: false)
    negated ? "the card is not nonfoil-only" : "the card is only available in nonfoil"
  end
end
