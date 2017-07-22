class ConditionColorsExclusive < ConditionColors
  def match?(card)
    super and (card.colors.chars - @colors_query).empty?
  end

  def to_s
    "c!#{@colors_query.join}"
  end
end
