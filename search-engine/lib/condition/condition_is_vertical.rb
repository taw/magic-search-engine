class ConditionIsVertical < ConditionSimple
  def match?(card)
    types = card.types
    (types & ["plane", "phenomenon", "battle"]).empty?
  end

  def to_s
    "is:vertical"
  end
end
