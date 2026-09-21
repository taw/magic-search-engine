class ConditionIsMtgo < ConditionSimple
  def match?(card)
    card.mtgo?
  end

  def to_s
    "game:mtgo"
  end

  def explain
    "the card is available on Magic Online"
  end
end
