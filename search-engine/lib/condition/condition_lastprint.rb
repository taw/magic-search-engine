class ConditionLastprint < ConditionPrint
  def to_s
    timify_to_s "lastprint#{@op}#{maybe_quote(@date)}"
  end

  # Unlike print:, time: changes which printings count here
  def explain(negated: false)
    timify_explain(super)
  end

  private

  def date_description
    "last printing"
  end

  def get_date(card, max_date)
    if max_date
      card.printings.map(&:release_date).compact.select{|d| d <= max_date}.max
    else
      card.last_release_date
    end
  end
end
