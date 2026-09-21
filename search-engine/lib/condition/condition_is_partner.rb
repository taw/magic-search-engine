class ConditionIsPartner < ConditionSimple
  def match?(card)
    !!card.partner?
  end

  def to_s
    "is:partner"
  end

  def explain
    "the card has partner"
  end
end
