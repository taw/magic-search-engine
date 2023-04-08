class ConditionVariantMisprint < ConditionSimple
  def match?(card)
    card.variant_misprint
  end

  def to_s
    "variant:misprint"
  end
end
