class ConditionIsDigital < ConditionSimple
  def match?(card)
    card.digital
  end

  def to_s
    "is:digital"
  end
end
