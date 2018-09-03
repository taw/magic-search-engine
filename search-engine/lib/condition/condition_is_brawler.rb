class ConditionIsBrawler < ConditionSimple
  def match?(card)
    return false if card.secondary?
    return true if card.types.include?("legendary") and (card.types.include?("creature") or card.types.include?("planeswalker"))
    false
  end

  def to_s
    "is:brawler"
  end
end
