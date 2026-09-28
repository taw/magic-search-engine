class ConditionIsFullart < ConditionSimple
  def match?(card)
    card.fullart
  end

  def to_s
    "is:fullart"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a full art card"
  end
end
