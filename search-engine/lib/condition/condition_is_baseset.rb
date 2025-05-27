class ConditionIsBaseset < ConditionSimple
  def match?(card)
    card.baseset?
  end

  def to_s
    "is:baseset"
  end
end
