class ConditionPrinted < Condition
  def initialize(op, date)
    @op = op
    @date = date
  end

  def match?(card)
    match_x_printed?(card, card.release_date)
  end

  def to_s
    "printed#{@op}#{@date}"
  end

  private

  def match_x_printed?(card, card_date)
    return false unless card_date
    card_date = Date.parse(card_date)

    # This is hacky beyond reason
    # This should go to initializer, but we don't have @db there
    # The whole system is just silly
    db = card.set.instance_eval{ @db }
    date = @date
    db.sets[date.downcase].tap do |set|
      date = set.release_date if set
    end

    # Fancy precision reduction algorithm is needed instead of placeholders like
    # "2001" -> "2001-01-01" as >=/> would require start of year, <=/< end of year
    # and = would require both anyway
    begin
      # Day date, keep full precision
      date = Date.parse(date)
    rescue
      if date =~ /\A\d{4}\z/
        date = Date.parse("#{date}-01-01")
        card_date = card_date.year
        date = date.year
      elsif date =~ /\A\d{4}-\d{1,2}\z/
        date = Date.parse("#{date}-01")
        card_date = [card_date.year, card_date.month]
        date = [date.year, date.month]
      end
    end

    case @op
    when "="
      card_date == date
    when ">="
      card_date >= date
    when ">"
      card_date > date
    when "<="
      card_date <= date
    when "<"
      card_date < date
    else
      raise
    end
  end
end
