class ConditionIsModal < ConditionSimple
  def match?(card)
    card.modal
  end

  def to_s
    "is:modal"
  end

  def explain(negated: false)
    negated ? "the card has no modes to choose from" : "the card has modes to choose from"
  end
end
