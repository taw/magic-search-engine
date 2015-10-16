class ConditionIsFunny < ConditionSimple
  # There are some one off funny cards elsewhere
  # Basic lands here aren't exactly funny
  # Shouldn't it just test border:silver ?
  def match?(card)
    %W[uh ug uqc].include?(card.set_code)
  end

  def to_s
    "is:funny"
  end
end
