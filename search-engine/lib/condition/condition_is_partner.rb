class ConditionIsPartner < ConditionSimple
  def match?(card)
    !!card.partner?
  end

  def to_s
    "is:partner"
  end

  def explain(negated: false)
    negated ? "the card has no partner" : "the card has partner"
  end
end
