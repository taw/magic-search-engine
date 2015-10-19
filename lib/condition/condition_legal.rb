class ConditionLegal < ConditionFormat
  def to_s
    "legal:#{maybe_quote(@format_name)}"
  end

  private

  def legality_ok?(legality)
    legality == "legal"
  end
end
