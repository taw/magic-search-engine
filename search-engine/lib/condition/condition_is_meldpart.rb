class ConditionIsMeldpart < ConditionSimple
  # Meld parts have one other part, meld results have two
  def match?(card)
    card.layout == "meld" and (card.others || []).size == 1
  end

  def to_s
    "is:meldpart"
  end

  def explain(negated: false)
    negated ? "the card does not meld into another card" : "the card melds into another card"
  end
end
