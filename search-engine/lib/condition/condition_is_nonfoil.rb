class ConditionIsNonfoil < ConditionSimple
  def match?(card)
    card.has_finish?(:nonfoil)
  end

  def to_s
    "is:nonfoil"
  end

  def explain(negated: false)
    "the card has #{negated ? "no" : "a"} nonfoil version"
  end
end
