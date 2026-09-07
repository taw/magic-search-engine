class ConditionIsHolofoil < ConditionSimple
  HOLOFOIL_RARITIES = %W[rare mythic special].freeze

  def match?(card)
    return false unless card.frame == "2015"
    return true if card.set_code == "ust" and card.rarity == "basic"
    return false unless HOLOFOIL_RARITIES.include?(card.rarity)
    return false if card.back?
    return false if card.types.include?("contraption")
    true
  end

  def to_s
    "is:holofoil"
  end
end
