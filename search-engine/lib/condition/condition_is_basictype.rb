class ConditionIsBasictype < ConditionSimple
  def match?(card)
    !(card.types & %w[plains island swamp mountain forest]).empty?
  end

  def to_s
    "is:basictype"
  end

  def explain(negated: false)
    negated ? "the card has no basic land type" : "the card has a basic land type"
  end
end
