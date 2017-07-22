class ConditionIsPromo < ConditionSimple
  def match?(card)
    card.set.type == "promo"
  end

  def to_s
    "is:promo"
  end
end
