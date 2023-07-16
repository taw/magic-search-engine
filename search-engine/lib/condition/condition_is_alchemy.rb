class ConditionIsAlchemy < ConditionSimple
  def match?(card)
    card.alchemy
  end

  def to_s
    "is:alchemy"
  end
end
