class ConditionFrameEffect < ConditionSimple
  def initialize(frame_effect)
    @frame_effect = frame_effect.downcase
  end

  def match?(card)
    card.frame_effects.include?(@frame_effect)
  end

  def to_s
    "frame:#{@frame_effect}"
  end

  def explain
    "the card has the #{@frame_effect} frame effect"
  end
end
