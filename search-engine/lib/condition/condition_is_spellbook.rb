class ConditionIsSpellbook < ConditionSimple
  def match?(card)
    !!card.in_spellbook
  end

  def to_s
    "is:spellbook"
  end
end
