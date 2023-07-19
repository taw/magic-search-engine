class ConditionHasAlchemy < ConditionSimple
  def match?(card)
    card.has_alchemy
  end

  def to_s
    "has:alchemy"
  end
end
