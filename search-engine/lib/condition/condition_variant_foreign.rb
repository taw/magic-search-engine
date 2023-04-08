class ConditionVariantForeign < ConditionSimple
  def match?(card)
    card.variant_foreign
  end

  def to_s
    "variant:foreign"
  end
end
