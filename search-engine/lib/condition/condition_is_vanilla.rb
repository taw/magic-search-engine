class ConditionIsVanilla < ConditionSimple
  def match?(card)
    card.text == ""
  end

  def to_s
    "is:vanilla"
  end
end
