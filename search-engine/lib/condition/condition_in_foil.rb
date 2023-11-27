class ConditionInFoil < ConditionIn
  def match?(card)
    card.foiling != :nonfoil
  end

  def to_s
    "in:foil"
  end
end
