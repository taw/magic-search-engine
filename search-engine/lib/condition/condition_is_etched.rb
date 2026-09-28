class ConditionIsEtched < ConditionSimple
  def match?(card)
    card.has_finish?(:etched)
  end

  def to_s
    "is:etched"
  end

  def explain(negated: false)
    "the card has #{negated ? "no" : "an"} etched foil version"
  end
end
