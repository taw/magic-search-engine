class ConditionLayout < ConditionSimple
  def initialize(layout)
    @layout = layout.downcase
  end

  def match?(card)
    card.layout == @layout
  end

  def to_s
    "layout:#{@layout}"
  end
end
