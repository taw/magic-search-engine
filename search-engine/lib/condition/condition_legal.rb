class ConditionLegal < ConditionFormat
  def to_s
    timify_to_s "legal:#{maybe_quote(@format_name)}"
  end

  private

  def card_ok?(card)
    @format.legal?(card)
  end
end
