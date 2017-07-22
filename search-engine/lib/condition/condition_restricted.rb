class ConditionRestricted < ConditionFormat
  def to_s
    timify_to_s "restricted:#{maybe_quote(@format_name)}"
  end

  private

  def legality_ok?(legality)
    legality == "restricted"
  end
end
