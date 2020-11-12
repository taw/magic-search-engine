class ConditionInShandalar < ConditionIn
  def match?(card)
    card.shandalar?
  end

  def to_s
    "in:shandalar"
  end
end
