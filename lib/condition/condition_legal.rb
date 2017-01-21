class ConditionLegal < ConditionFormat
  def to_s
    if @time
      "(time:#{maybe_quote(@time)} legal:#{maybe_quote(@format_name)})"
    else
      "legal:#{maybe_quote(@format_name)}"
    end
  end

  private

  def legality_ok?(legality)
    legality == "legal"
  end
end
