class ConditionColorIdentity < ConditionSimple
  def initialize(ci)
    # Ignore "m"/"l" in query
    # Treat "cr" as "c"
    @commander_ci = ci.downcase.gsub(/ml/, "").chars.uniq
  end

  def match?(card)
    card_ci = card.color_identity.chars
    return card_ci == [] if @commander_ci.include?("c")
    card_ci.all? do |color|
      @commander_ci.include?(color)
    end
  end

  def to_s
    "ci:#{@commander_ci.join}"
  end
end
