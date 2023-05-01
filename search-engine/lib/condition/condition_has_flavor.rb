class ConditionHasFlavor < ConditionSimple
  def match?(card)
    !card.flavor.empty?
  end

  def to_s
    "has:flavor"
  end
end
