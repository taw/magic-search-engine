class ConditionIsShandalar < ConditionSimple
  def match?(card)
    card.shandalar?
  end

  def to_s
    "game:shandalar"
  end
end
