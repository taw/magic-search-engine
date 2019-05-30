class ConditionLayout < ConditionSimple
  def initialize(layout)
    @layout = layout.downcase
    # mtgjson v3 vs v4 differences
    @layout = "double-faced" if @layout == "dfc"
    @layout = "planar" if @layout == "plane"
    @layout = "planar" if @layout == "phenomenon"
  end

  def match?(card)
    card.layout == @layout
  end

  def to_s
    "layout:#{@layout}"
  end
end
