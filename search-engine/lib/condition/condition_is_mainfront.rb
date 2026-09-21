class ConditionIsMainfront < ConditionSimple
  def match?(card)
    card.main_front?
  end

  def to_s
    "is:mainfront"
  end

  def explain
    "the card is the single face each physical card is filed under (the front of a double-faced card, the left half of a split card, or the creature half of an adventure)"
  end
end
