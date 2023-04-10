class ConditionIsPhyrexian < ConditionSimple
  def match?(card)
    mana_cost = card.mana_cost or return false
    mana_cost.include?("p")
  end

  def to_s
    "is:phyrexian"
  end
end
