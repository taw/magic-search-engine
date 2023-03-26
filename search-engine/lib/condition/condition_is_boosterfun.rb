class ConditionIsBoosterfun < ConditionSimple
  def match?(card)
    valid_sets = ["eld", "thb", "iko", "m21", "znr", "khm", "stx", "afr", "mid", "vow", "neo", "snc", "dmu", "bro", "one", "2xm", "mh2", "clb", "cmr", "2x2", "dmr", "unf", "bot"]
    return false unless valid_sets.include?(card.printing.set)
    return false if card.foiling == "foilonly"
	return false if card.set.types.include?("promo")
    card.frame_effects.include?("showcase") or card.border.include?("borderless") or card.frame_effects.include?("inverted") or card.frame.include?("old")
  end

  def to_s
    "is:boosterfun"
  end
end
