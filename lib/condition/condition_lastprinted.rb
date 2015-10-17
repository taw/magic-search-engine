class ConditionLastprinted < ConditionPrinted
  def to_s
    "lastprinted#{@op}#{@date}"
  end

  private

  def get_date(card, max_date)
    if max_date
      card.printings.map(&:release_date).compact.select{|d| d <= max_date}.max
    else
      card.last_release_date
    end
  end
end
