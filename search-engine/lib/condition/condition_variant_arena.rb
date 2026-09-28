class ConditionVariantArena < ConditionSimple
  def match?(card)
    card.variant_arena
  end

  def to_s
    "variant:arena"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}an Arena-only variant of another card in the same set"
  end
end
