class ConditionBanned < ConditionFormat
  def match?(card)
    card.legality(@format) == "banned"
  end

  def to_s
    "banned:#{maybe_quote(@format)}"
  end
end
