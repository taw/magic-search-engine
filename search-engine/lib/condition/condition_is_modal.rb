class ConditionIsModal < ConditionSimple
  def match?(card)
    card.modal
  end

  def to_s
    "is:modal"
  end

  def explain
    "the card has modes to choose from"
  end
end
