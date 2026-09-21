class ConditionVariantForeign < ConditionSimple
  def match?(card)
    card.variant_foreign
  end

  def to_s
    "variant:foreign"
  end

  def explain
    "the card is a foreign-language variant with different art"
  end
end
