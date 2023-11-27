class ConditionInNonfoil < ConditionIn
  def match?(card)
    card.foiling != :foilonly
  end

  def to_s
    "in:nonfoil"
  end
end
