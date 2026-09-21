class ConditionIsArena < ConditionSimple
  def match?(card)
    card.arena?
  end

  def to_s
    "game:arena"
  end

  def explain
    "the card is available on Arena"
  end
end
