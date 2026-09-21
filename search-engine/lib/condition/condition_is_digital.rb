class ConditionIsDigital < ConditionSimple
  def match?(card)
    card.digital
  end

  def to_s
    "is:digital"
  end

  def explain(negated: false)
    negated ? "the card is not digital-only" : "the card is digital-only (MTGO or Arena)"
  end
end
