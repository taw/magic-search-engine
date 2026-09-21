class ConditionIsDfc < ConditionSimple
  def match?(card)
    layout = card.layout
    layout == "transform" or layout == "meld" or layout == "modaldfc"
  end

  def to_s
    "is:dfc"
  end

  def explain
    "the card is double-faced (transform, meld, or modal)"
  end
end
