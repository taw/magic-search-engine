class ConditionHasSpecialized < ConditionSimple
  def match?(card)
    !!card.specializes
  end

  def to_s
    "has:specialized"
  end

  def explain
    "the card can be specialized into another card"
  end
end
