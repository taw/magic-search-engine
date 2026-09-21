class ConditionIsXmage < ConditionSimple
  def match?(card)
    card.xmage?
  end

  def to_s
    "game:xmage"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}available on Xmage"
  end
end
