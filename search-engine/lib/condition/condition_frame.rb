class ConditionFrame < ConditionSimple
  def initialize(frame)
    @frame = frame.downcase
    @frame = "2003" if @frame == "modern"
    @frame = "2015" if @frame == "m15"
  end

  def match?(card)
    case @frame
    when "old"
      card.frame == "1993" or card.frame == "1997"
    when "new"
      card.frame != "1993" and card.frame != "1997"
    else
      card.frame == @frame
    end
  end

  def to_s
    "is:#{@frame}"
  end
end
