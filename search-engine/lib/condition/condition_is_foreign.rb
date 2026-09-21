class ConditionIsForeign < ConditionSimple
  def match?(card)
    card.language
  end

  def to_s
    "is:foreign"
  end

  def explain
    "the card is available only in a foreign-language printing, either a promo or a foreign-only variant"
  end
end
