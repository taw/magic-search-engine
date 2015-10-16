class ConditionLegal < ConditionFormat
  def match?(card)
    card.legality(@format) == "legal"
  end

  def to_s
    "legal:#{maybe_quote(@format)}"
  end
end
