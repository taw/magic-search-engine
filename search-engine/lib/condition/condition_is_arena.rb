class ConditionIsArena < ConditionSimple
  def match?(card)
    card.arena?
  end

  def to_s
    "game:arena"
  end
end
