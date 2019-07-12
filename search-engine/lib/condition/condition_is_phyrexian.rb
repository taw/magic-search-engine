class ConditionIsPhyrexian < ConditionSimple
  def match?(card)
    mana_hash = card.mana_hash or return false
    # These are weirdly alphabetized internally
    !(mana_hash.keys & ["pw", "pu", "bp", "pr", "gp"]).empty?
  end

  def to_s
    "is:phyrexian"
  end
end
