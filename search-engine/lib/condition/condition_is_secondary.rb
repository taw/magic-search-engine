class ConditionIsSecondary < ConditionSimple
  def match?(card)
    card.secondary?
  end

  def to_s
    "is:secondary"
  end

  def explain
    "the card is the not-directly-playable part of a double-faced, meld, flip, or aftermath card"
  end
end
