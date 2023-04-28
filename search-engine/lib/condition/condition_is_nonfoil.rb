class ConditionIsNonfoil < ConditionSimple
  def match?(card)
    card.foiling != "foilonly"
  end

  def to_s
    "is:nonfoil"
  end
end
