class ConditionHasPartner < ConditionSimple
  def match?(card)
    !!card.partner
  end

  def to_s
    "has:partner"
  end

  def explain
    "the card has a partner"
  end
end
