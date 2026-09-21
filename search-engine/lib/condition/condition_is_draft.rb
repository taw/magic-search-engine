class ConditionIsDraft < ConditionSimple
  def match?(card)
    return true if card.types.include?("conspiracy")
    return true if card.text.include?("as you draft it")
    return true if card.text.include?("you drafted")
    return true if card.text.include?("draft") and card.text.include?("face up")
    false
  end

  def to_s
    "is:draft"
  end

  def explain
    "the card cares about the draft process, including conspiracies"
  end
end
