class ConditionIsPhyrexian < ConditionSimple
  def match?(card)
    mana_cost = card.mana_cost or return false
    mana_cost.include?("p")
  end

  def to_s
    "is:phyrexian"
  end

  def explain(negated: false)
    negated ? "the card has no Phyrexian mana in its cost" : "the card has Phyrexian mana in its cost"
  end
end
