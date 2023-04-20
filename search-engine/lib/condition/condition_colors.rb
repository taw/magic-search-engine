# This is basically MCI leftover
# You should use c=, c>=, c<= etc.
class ConditionColors < ConditionSimple
  def initialize(colors)
    @colors_query = colors.downcase.chars
    @colors_c = @colors_query.include?("c")
    @colors_m = @colors_query.include?("m")
    @colors_query_actual_colors = @colors_query - ["c", "m"]
    @colors_query_actual_colors.each do |q|
      raise "Unknown color: #{q}" unless q =~ /\A[wubrg]\z/
    end
  end

  # Old c: system removed
  # Now it's >= except for :c and :m
  def match?(card)
    card_colors = card.colors
    return card_colors.size == 0 if @colors_c
    return false if @colors_m and card_colors.size <= 1
    @colors_query_actual_colors.all? do |q|
      card_colors.include?(q)
    end
  end

  def to_s
    "c:#{@colors_query.join}"
  end
end
