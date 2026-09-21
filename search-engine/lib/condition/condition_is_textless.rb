class ConditionIsTextless < ConditionSimple
  def match?(card)
    card.textless
  end

  def to_s
    "is:textless"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}textless"
  end
end
