class ConditionIsHolofoil < ConditionSimple
  def match?(card)
    return false unless card.frame == "m15"
    return true if card.set_code == "ust" and card.rarity == "basic"
    return false unless %W[rare mythic special].include?(card.rarity)
    return false if card.back?
    return false if card.types.include?("contraption")
    true
  end

  def to_s
    "is:holofoil"
  end
end
