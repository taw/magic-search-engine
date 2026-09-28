class ConditionVariantMisprint < ConditionSimple
  def match?(card)
    card.variant_misprint
  end

  def to_s
    "variant:misprint"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a misprinted variant of another card in the same set"
  end
end
