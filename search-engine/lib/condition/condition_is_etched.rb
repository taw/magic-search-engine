class ConditionIsEtched < ConditionSimple
  def match?(card)
    card.etched
  end

  def to_s
    "is:etched"
  end
end
