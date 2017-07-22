class ConditionIsReprint < ConditionSimple
  def match?(card)
    card.age > 0
  end

  def to_s
    "is:reprint"
  end
end
