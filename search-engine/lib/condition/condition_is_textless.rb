class ConditionIsTextless < ConditionSimple
  def match?(card)
    card.textless
  end

  def to_s
    "is:textless"
  end

  def explain
    "the card is textless"
  end
end
