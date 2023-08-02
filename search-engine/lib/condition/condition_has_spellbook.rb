class ConditionHasSpellbook < ConditionSimple
  def match?(card)
    !!card.spellbook
  end

  def to_s
    "has:spellbook"
  end
end
