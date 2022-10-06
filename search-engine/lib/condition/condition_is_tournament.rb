class ConditionIsTournament < ConditionSimple
  def match?(card)
    !card.nontournament
  end

  def to_s
    "is:tournament"
  end
end
