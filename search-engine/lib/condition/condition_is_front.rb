class ConditionIsFront < ConditionSimple
  def match?(card)
    card.front?
  end

  def to_s
    "is:front"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}on the front face"
  end
end
