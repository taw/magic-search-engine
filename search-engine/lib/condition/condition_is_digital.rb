class ConditionIsDigital < ConditionSimple
  def match?(card)
    card.digital
  end

  def to_s
    "is:digital"
  end

  def explain
    "the card is digital-only (MTGO or Arena)"
  end
end
