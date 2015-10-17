class ConditionRestricted < ConditionFormat
  def to_s
    "restricted:#{maybe_quote(@format)}"
  end

  private

  def legality_ok?(legality)
    legality == "restricted"
  end
end
