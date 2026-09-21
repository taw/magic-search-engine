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

  def explain(negated: false)
    "the border #{negated ? "isn't" : "is"} #{@border}"
  end
end
