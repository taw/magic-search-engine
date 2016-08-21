class ConditionLastprint < ConditionPrint
  def to_s
    "lastprint#{@op}#{@date}"
  end

  private

  def get_date(card, max_date)
    if max_date
      card.card.printings.map(&:release_date).compact.select{|d| d <= max_date}.max
    else
      card.card.last_release_date @type
    end
  end
end
