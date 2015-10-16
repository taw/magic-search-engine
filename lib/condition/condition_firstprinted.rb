class ConditionFirstprinted < ConditionPrinted
  def match?(card)
    match_x_printed?(card, card.first_release_date)
  end

  def to_s
    "firstprinted#{@op}#{@date}"
  end
end
