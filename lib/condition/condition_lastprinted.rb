class ConditionLastprinted < ConditionPrinted
  def match?(card)
    match_x_printed?(card, card.last_release_date)
  end

  def to_s
    "lastprinted#{@op}#{@date}"
  end
end
