class ConditionIsPermanent < ConditionSimple
  def match?(card)
    card.types.all?{|t| t != "instant" and t != "sorcery" }
  end

  def to_s
    "is:permanent"
  end
end
