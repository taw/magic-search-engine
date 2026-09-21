class ConditionInShandalar < ConditionIn
  def match?(card)
    card.shandalar?
  end

  def to_s
    "in:shandalar"
  end

  def explain
    "the card has a printing available on Shandalar"
  end
end
