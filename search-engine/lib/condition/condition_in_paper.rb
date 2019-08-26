class ConditionInPaper < ConditionIn
  def match?(card)
    card.paper?
  end

  def to_s
    "in:paper"
  end
end
