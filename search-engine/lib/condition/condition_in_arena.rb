class ConditionInArena < ConditionIn
  def match?(card)
    card.arena?
  end

  def to_s
    "in:arena"
  end

  def explain
    "the card has a printing available on Arena"
  end
end
