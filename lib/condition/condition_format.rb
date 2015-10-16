class ConditionFormat < ConditionSimple
  def initialize(format)
    @format = format.downcase
    @format = "commander" if @format == "edh"
  end

  def match?(card)
    legality = card.legality(@format)
    legality == "legal" or legality == "restricted"
  end

  def to_s
    "f:#{maybe_quote(@format)}"
  end
end
