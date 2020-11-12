class ConditionIsXmage < ConditionSimple
  def match?(card)
    card.xmage?
  end

  def to_s
    "game:xmage"
  end
end
