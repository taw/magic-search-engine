class ConditionIsHorizontal < ConditionSimple
  def match?(card)
    types = card.types
    !(types & ["plane", "phenomenon", "battle"]).empty?
  end

  def to_s
    "is:horizontal"
  end

  def explain(negated: false)
    negated ? "the card is vertical" : "the card is horizontal"
  end
end
