class ConditionInXmage < ConditionIn
  def match?(card)
    card.xmage?
  end

  def to_s
    "in:xmage"
  end

  def explain
    "the card has a printing available on Xmage"
  end
end
