class ConditionVariantArena < ConditionSimple
  def match?(card)
    card.variant_arena
  end

  def to_s
    "variant:arena"
  end

  def explain
    "the card is an Arena-only variant of another card in the same set"
  end
end
