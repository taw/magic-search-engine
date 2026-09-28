class ConditionIsDfc < ConditionSimple
  def match?(card)
    layout = card.layout
    layout == "transform" or layout == "meld" or layout == "modaldfc"
  end

  def to_s
    "is:dfc"
  end

  def explain(negated: false)
    negated ? "the card is not double-faced" : "the card is double-faced (transform, meld, or modal)"
  end
end
