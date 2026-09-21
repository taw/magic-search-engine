class ConditionInNonfoil < ConditionIn
  def match?(card)
    card.has_finish?(:nonfoil)
  end

  def to_s
    "in:nonfoil"
  end

  def explain(negated: false)
    "the card has #{negated ? "no" : "a"} nonfoil version"
  end
end
