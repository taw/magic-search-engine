class ConditionRestricted < ConditionFormat
  def match?(card)
    card.legality(@format) == "restricted"
  end

  def to_s
    "restricted:#{maybe_quote(@format)}"
  end
end
