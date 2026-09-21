class ConditionIsBack < ConditionSimple
  def match?(card)
    card.back?
  end

  def to_s
    "is:back"
  end

  def explain
    "the card is the back face of a double-faced or meld card"
  end
end
