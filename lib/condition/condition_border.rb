class ConditionBorder < ConditionSimple
  def initialize(border)
    @border = border.downcase
  end

  def match?(card)
    card.border == @border
  end

  def to_s
    "border:#{@border}"
  end
end
