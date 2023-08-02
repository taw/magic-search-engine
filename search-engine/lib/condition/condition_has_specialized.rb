class ConditionHasSpecialized < ConditionSimple
  def match?(card)
    !!card.specializes
  end

  def to_s
    "has:specialized"
  end
end
