class ConditionIsShandalar < ConditionSimple
  def match?(card)
    card.shandalar?
  end

  def to_s
    "game:shandalar"
  end

  def explain
    "the card is available on Shandalar"
  end
end
