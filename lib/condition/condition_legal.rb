class ConditionLegal < ConditionFormat
  def to_s
    "legal:#{maybe_quote(@format)}"
  end

  private

  def legality_ok?(legality)
    legality == "legal"
  end
end
