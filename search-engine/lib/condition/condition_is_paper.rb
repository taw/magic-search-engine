class ConditionIsPaper < ConditionSimple
  def match?(card)
    card.paper?
  end

  def to_s
    "game:paper"
  end
end
