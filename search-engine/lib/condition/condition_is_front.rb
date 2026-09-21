class ConditionIsFront < ConditionSimple
  def match?(card)
    card.front?
  end

  def to_s
    "is:front"
  end

  def explain
    "the card is on the front face, not the back of a double-faced or meld card"
  end
end
