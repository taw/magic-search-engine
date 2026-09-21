class ConditionIsSpellbook < ConditionSimple
  def match?(card)
    !!card.in_spellbook
  end

  def to_s
    "is:spellbook"
  end

  def explain
    "the card is in a spellbook (Arena digital-only)"
  end
end
