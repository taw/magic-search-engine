class ConditionIsVertical < ConditionSimple
  def match?(card)
    types = card.types
    (types & ["plane", "phenomenon", "battle"]).empty?
  end

  def to_s
    "is:vertical"
  end

  def explain(negated: false)
    negated ? "the card is a Plane, Phenomenon, or Battle" : "the card is vertical, not a Plane, Phenomenon, or Battle"
  end
end
