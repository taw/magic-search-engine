class ConditionBanned < ConditionFormat
  def to_s
    timify_to_s "banned:#{maybe_quote(@format_name)}"
  end

  private

  def legality_ok?(legality)
    legality == "banned"
  end
end
