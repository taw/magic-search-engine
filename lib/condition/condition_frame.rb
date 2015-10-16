class ConditionFrame < Condition
  def initialize(frame)
    @frame = frame.downcase
  end

  def match?(card)
    card.frame == @frame
  end

  def to_s
    "frame:#{@frame}"
  end
end
