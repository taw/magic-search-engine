class ConditionInXmage < ConditionIn
  def match?(card)
    card.xmage?
  end

  def to_s
    "in:xmage"
  end
end
