class ConditionIsFullart < ConditionSimple
  def match?(card)
    card.fullart
  end

  def to_s
    "is:fullart"
  end
end
