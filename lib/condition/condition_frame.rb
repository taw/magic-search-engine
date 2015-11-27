class ConditionFrame < ConditionSimple
  def initialize(frame)
    @frame = frame.downcase
  end

  def match?(card)
    card.frame == @frame
  end

  def to_s
    "is:#{@frame}"
  end
end
