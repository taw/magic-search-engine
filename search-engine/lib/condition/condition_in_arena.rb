class ConditionInArena < ConditionIn
  def match?(card)
    card.arena?
  end

  def to_s
    "in:arena"
  end
end
