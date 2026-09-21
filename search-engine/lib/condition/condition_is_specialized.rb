class ConditionIsSpecialized < ConditionSimple
  def match?(card)
    !!card.specialized
  end

  def to_s
    "is:specialized"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a specialized version of another card (Arena digital-only)"
  end
end
