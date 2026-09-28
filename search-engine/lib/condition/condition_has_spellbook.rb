class ConditionHasSpellbook < ConditionSimple
  def match?(card)
    !!card.spellbook
  end

  def to_s
    "has:spellbook"
  end

  def explain(negated: false)
    negated ? "the card has no associated spellbook" : "the card has an associated spellbook"
  end
end
