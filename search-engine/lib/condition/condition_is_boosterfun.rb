class ConditionIsBoosterfun < ConditionSimple
  def match?(card)
    return false if card.foiling == "foilonly"
    return false if card.frame_effects.include?("extendedart")
    card.promo_types.include?("boosterfun")
  end

  def to_s
    "is:boosterfun"
  end
end
