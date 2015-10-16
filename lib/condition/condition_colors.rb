class ConditionColors < ConditionSimple
  def initialize(colors)
    @colors_query = colors.downcase.chars
    @colors_c = @colors_query.include?("c")
    @colors_l = @colors_query.include?("l")
    @colors_m = @colors_query.include?("m")
    @colors_query_actual_colors = @colors_query - ["l", "c", "m"]
  end

  # c: system is rather illogical
  # This seems to be the logic as implemented
  def match?(card)
    card_colors = card.colors.chars
    return true if @colors_c and card_colors.size == 0 and not card.types.include?("land")
    # Dryad Arbor is not c:l
    return true if @colors_l and card_colors.size == 0 and card.types.include?("land")
    return false if @colors_m and card_colors.size <= 1
    return true if @colors_m and @colors_query_actual_colors.empty?
    @colors_query_actual_colors.any? do |q|
      raise "Unknown color: #{q}" unless q =~ /\A[wubrg]\z/
      card_colors.include?(q)
    end
  end

  def to_s
    "c:#{@colors_query.join}"
  end
end
