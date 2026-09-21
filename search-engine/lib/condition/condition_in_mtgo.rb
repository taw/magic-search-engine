class ConditionInMtgo < ConditionIn
  def match?(card)
    card.mtgo?
  end

  def to_s
    "in:mtgo"
  end

  def explain
    "the card has a printing available on Magic Online"
  end
end
