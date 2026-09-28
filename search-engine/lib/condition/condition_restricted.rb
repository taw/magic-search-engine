class ConditionRestricted < ConditionFormat
  def to_s
    timify_to_s "restricted:#{maybe_quote(@format_name)}"
  end

  private

  def card_ok?(card)
    @format.restricted?(card)
  end

  def verb
    "is restricted in"
  end

  def verb_negated
    "is not restricted in"
  end
end
