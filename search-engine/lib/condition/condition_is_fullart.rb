class ConditionIsFullart < ConditionSimple
  def match?(card)
    card.fullart
  end

  def to_s
    "is:fullart"
  end

  def explain
    "the card is a full art card"
  end
end
