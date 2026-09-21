class ConditionIsArena < ConditionSimple
  def match?(card)
    card.arena?
  end

  def to_s
    "game:arena"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}available on Arena"
  end
end
