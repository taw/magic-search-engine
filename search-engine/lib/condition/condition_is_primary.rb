class ConditionIsPrimary < ConditionSimple
  def match?(card)
    card.primary?
  end

  def to_s
    "is:primary"
  end

  def explain(negated: false)
    negated ? "the card is neither a regular card nor the directly playable part of a double-faced, meld, flip, or aftermath card" : "the card is a regular card, or the directly playable part of a double-faced, meld, flip, or aftermath card"
  end
end
