class ConditionBanned < ConditionFormat
  def to_s
    if @time
      "(time:#{maybe_quote(@time)} banned:#{maybe_quote(@format_name)})"
    else
      "banned:#{maybe_quote(@format_name)}"
    end
  end

  private

  def legality_ok?(legality)
    legality == "banned"
  end
end
