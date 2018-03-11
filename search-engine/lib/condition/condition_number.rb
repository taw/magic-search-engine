class ConditionNumber < ConditionSimple
  def initialize(number)
    @number = number.downcase
  end

  def match?(card)
    card.number.to_s.downcase == @number
  end

  def to_s
    "number:#{maybe_quote(@artist)}"
  end
end
