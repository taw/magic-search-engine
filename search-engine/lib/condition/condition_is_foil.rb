class ConditionIsFoil < ConditionSimple
  def match?(card)
    card.foiling != :nonfoil
  end

  def to_s
    "is:foil"
  end
end
