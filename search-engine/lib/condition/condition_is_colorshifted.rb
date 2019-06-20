class ConditionIsColorshifted < ConditionSimple
  def match?(card)
    card.frame_effect == "colorshifted"
  end

  def to_s
    "is:colorshifted"
  end
end
