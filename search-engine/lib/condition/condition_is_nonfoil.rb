class ConditionIsNonfoil < ConditionSimple
  def match?(card)
    card.has_finish?(:nonfoil)
  end

  def to_s
    "is:nonfoil"
  end

  def explain
    "the card has a nonfoil version"
  end
end
