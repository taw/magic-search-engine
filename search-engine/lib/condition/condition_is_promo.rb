class ConditionIsPromo < ConditionSimple
  def match?(card)
    card.set.types.include?("promo")
  end

  def to_s
    "is:promo"
  end
end
