class ConditionIsMainfront < ConditionSimple
  def match?(card)
    card.main_front?
  end

  def to_s
    "is:mainfront"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}the main front face"
  end
end
