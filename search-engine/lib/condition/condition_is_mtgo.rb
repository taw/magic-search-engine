class ConditionIsMtgo < ConditionSimple
  def match?(card)
    card.mtgo?
  end

  def to_s
    "game:mtgo"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}available on Magic Online"
  end
end
