class ConditionHasSpecialized < ConditionSimple
  def match?(card)
    !!card.specializes
  end

  def to_s
    "has:specialized"
  end

  def explain(negated: false)
    negated ? "the card can't be specialized into another card" : "the card can be specialized into another card"
  end
end
