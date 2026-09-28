class ConditionVariantForeign < ConditionSimple
  def match?(card)
    card.variant_foreign
  end

  def to_s
    "variant:foreign"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a foreign-language variant with different art"
  end
end
