class ConditionIsSfc < ConditionSimple
  def match?(card)
    layout = card.layout
    layout != "transform" and layout != "meld" and layout != "modaldfc"
  end

  def to_s
    "is:sfc"
  end

  def explain(negated: false)
    negated ? "the card is double-faced (transform, meld, or modal)" : "the card is single-faced, not double-faced (transform, meld, or modal)"
  end
end
