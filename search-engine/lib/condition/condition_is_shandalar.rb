class ConditionIsShandalar < ConditionSimple
  def match?(card)
    card.shandalar?
  end

  def to_s
    "game:shandalar"
  end

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}available on Shandalar"
  end
end
