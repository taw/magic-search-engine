class ConditionIsHybrid < ConditionSimple
  def match?(card)
    mana_hash = card.mana_hash or return false
    # Alphabetized internally
    !(mana_hash.keys & ["uw", "bw", "rw", "gw", "bu", "ru", "gu", "br", "bg", "gr", "2w", "2u", "2b", "2r", "2g"]).empty?
  end

  def to_s
    "is:hybrid"
  end
end
