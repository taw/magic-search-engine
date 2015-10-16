class ConditionFlavor < Condition
  def initialize(flavor)
    @flavor = flavor.downcase
  end

  def match?(card)
    card.flavor.downcase.include?(@flavor)
  end

  def to_s
    "ft:#{maybe_quote(@flavor)}"
  end
end
