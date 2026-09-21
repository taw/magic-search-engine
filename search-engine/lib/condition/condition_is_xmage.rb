class ConditionIsXmage < ConditionSimple
  def match?(card)
    card.xmage?
  end

  def to_s
    "game:xmage"
  end

  def explain
    "the card is available on Xmage"
  end
end
