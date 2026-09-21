class ConditionVariantMisprint < ConditionSimple
  def match?(card)
    card.variant_misprint
  end

  def to_s
    "variant:misprint"
  end

  def explain
    "the card is a misprinted variant of another card in the same set"
  end
end
