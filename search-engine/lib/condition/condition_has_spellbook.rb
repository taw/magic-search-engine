class ConditionHasSpellbook < ConditionSimple
  def match?(card)
    !!card.spellbook
  end

  def to_s
    "has:spellbook"
  end

  def explain
    "the card has an associated spellbook"
  end
end
