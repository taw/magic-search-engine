class ConditionVariantArena < ConditionSimple
  def match?(card)
    card.variant_arena
  end

  def to_s
    "variant:arena"
  end
end
