class ConditionFirstprint < ConditionPrint
  def to_s
    "firstprint#{@op}#{@date}"
  end

  private

  def get_date(card, max_date)
    if max_date
      card.card.printings.map(&:release_date).compact.select{|d| d <= max_date}.min
    else
      card.card.first_release_date @type
    end
  end
end
