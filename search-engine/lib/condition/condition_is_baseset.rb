class ConditionIsBaseset < ConditionSimple
  def match?(card)
    card.baseset?
  end

  def to_s
    "is:baseset"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}in the base set"
  end
end
