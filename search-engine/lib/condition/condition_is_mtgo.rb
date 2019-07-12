class ConditionIsMtgo < ConditionSimple
  def match?(card)
    card.mtgo?
  end

  def to_s
    "game:mtgo"
  end
end
