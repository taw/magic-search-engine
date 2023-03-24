class ConditionIsBoosterfun < ConditionSimple
  def match?(card)
    return false if card.foiling == "foilonly"
    card.frame_effects.include?("showcase") or card.border.include?("borderless")
  end

  def to_s
    "is:boosterfun"
  end
end
