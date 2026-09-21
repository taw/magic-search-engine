class ConditionIsFront < ConditionSimple
  def match?(card)
    card.front?
  end

  def to_s
    "is:front"
  end

  def explain(negated: false)
    negated ? "the card is on the back face of a double-faced or meld card" : "the card is on the front face, not the back of a double-faced or meld card"
  end
end
