class ConditionIsReprint < ConditionSimple
  def match?(card)
    card.age > 0
  end

  def to_s
    "is:reprint"
  end

  def explain
    "the card is a reprint"
  end
end
