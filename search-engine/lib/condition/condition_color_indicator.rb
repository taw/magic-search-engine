class ConditionColorIndicator < ConditionSimple
  def initialize(indicator)
    @indicator = indicator.downcase.gsub(/ml/, "").chars.to_set
    @indicator_name = Color.color_indicator_name(@indicator)
  end

  # Only exact match
  # For "has no color indicator" use -ind:*
  def match?(card)
    card.color_indicator and @indicator_name == card.color_indicator
  end

  def to_s
    "ind:#{@indicator.to_a.join}"
  end
end
