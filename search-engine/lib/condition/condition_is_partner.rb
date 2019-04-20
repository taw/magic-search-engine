class ConditionIsPartner < ConditionSimple
  def match?(card)
    !!card.partner?
  end

  def to_s
    "is:partner"
  end
end
