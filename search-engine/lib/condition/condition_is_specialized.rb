class ConditionIsSpecialized < ConditionSimple
  def match?(card)
    !!card.specialized
  end

  def to_s
    "is:specialized"
  end
end
