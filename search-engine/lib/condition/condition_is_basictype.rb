class ConditionIsBasictype < ConditionSimple
  def match?(card)
    !(card.types & %w[plains island swamp mountain forest]).empty?
  end

  def to_s
    "is:basictype"
  end

  def explain
    "the card has a basic land type (Plains, Island, Swamp, Mountain, or Forest)"
  end
end
