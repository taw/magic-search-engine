class ConditionIsOversized < ConditionSimple
  def match?(card)
    types = card.types
    types.include?("plane") or types.include?("phenomenon") or types.include?("scheme")
  end

  def to_s
    "is:oversized"
  end
end
