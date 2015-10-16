class ConditionColorsExclusive < ConditionColors
  def match?(card)
    super and (card.colors.chars - @colors_query).empty?
  end

  def to_s
    "ci:#{@colors_query.join}"
  end
end
