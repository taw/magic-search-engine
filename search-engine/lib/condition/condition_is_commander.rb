class ConditionIsCommander < ConditionSimple
  def match?(card)
    return false if card.secondary
    return true if card.types.include?("legendary") and card.types.include?("creature")
    if card.types.include?("planeswalker")
      return true if card.text =~ /\bcan be your commander\b/
    end
    false
  end

  def to_s
    "is:commander"
  end
end
