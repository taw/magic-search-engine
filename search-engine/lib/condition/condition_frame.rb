class ConditionFrame < ConditionSimple
  def initialize(frame)
    @frame = frame.downcase
  end

  def match?(card)
    return card.frame == "modern" || card.frame == "m15" if @frame == "new"
    card.frame == @frame
  end

  def to_s
    "is:#{@frame}"
  end
end
