class ConditionIsCustom < ConditionSimple
  def match?(card)
    return true if card.custom?
    false
  end

  def to_s
    "is:custom"
  end
end
