class ConditionIsColorshifted < ConditionSimple
  def match?(card)
    card.frame_effects.include?("colorshifted")
  end

  def to_s
    "is:colorshifted"
  end
end
