class ConditionIsForeign < ConditionSimple
  def match?(card)
    card.language
  end

  def to_s
    "is:foreign"
  end
end
