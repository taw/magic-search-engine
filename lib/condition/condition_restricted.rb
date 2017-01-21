class ConditionRestricted < ConditionFormat
  def to_s
    if @time
      "(time:#{maybe_quote(@time)} restricted:#{maybe_quote(@format_name)})"
    else
      "restricted:#{maybe_quote(@format_name)}"
    end
  end

  private

  def legality_ok?(legality)
    legality == "restricted"
  end
end
