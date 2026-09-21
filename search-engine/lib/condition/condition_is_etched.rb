class ConditionIsEtched < ConditionSimple
  def match?(card)
    card.has_finish?(:etched)
  end

  def to_s
    "is:etched"
  end

  def explain
    "the card has an etched foil version"
  end
end
