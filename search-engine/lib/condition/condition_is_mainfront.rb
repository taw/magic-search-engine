class ConditionIsMainfront < ConditionSimple
  def match?(card)
    card.main_front?
  end

  def to_s
    "is:mainfront"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}the single face each physical card is filed under (the front of a double-faced card, the left half of a split card, or the creature half of an adventure)"
  end
end
