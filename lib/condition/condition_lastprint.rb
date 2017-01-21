class ConditionLastprint < ConditionPrint
  def to_s
    timify_to_s "lastprint#{@op}#{maybe_quote(@date)}"
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
