class ConditionInNonfoil < ConditionIn
  def match?(card)
    card.has_finish?(:nonfoil)
  end

  def to_s
    "in:nonfoil"
  end
end
