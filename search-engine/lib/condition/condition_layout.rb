class ConditionLayout < ConditionSimple
  def initialize(is, layout)
    @is = is
    @layout = layout.downcase
    @layout = "double-faced" if @layout == "dfc"
  end

  def match?(card)
    return true if @is && @layout == "split" && card.layout == "aftermath"
    card.layout == @layout
  end

  def to_s
    return "is:#{@layout}" if @is
    "layout:#{@layout}"
  end
end
