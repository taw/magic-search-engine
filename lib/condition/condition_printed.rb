class ConditionPrinted < Condition
  def initialize(op, date)
    @op = op
    @date = date
  end

  def search(db)
    query_date, precision = parse_query_date(db)
    db.printings.select{|card| match_date?(card.release_date, query_date, precision)}.to_set
  end

  def to_s
    "printed#{@op}#{@date}"
  end

  private

  def parse_query_date(db)
    date = @date
    db.sets[date.downcase].tap do |set|
      return [set.release_date, 3] if set and set.release_date
    end
    # Fancy precision reduction algorithm is needed instead of placeholders like
    # "2001" -> "2001-01-01" as >=/> would require start of year, <=/< end of year
    # and = would require both anyway
    begin
      # Day date, keep full precision
      return [Date.parse(date), 3]
    rescue
      if date =~ /\A\d{4}\z/
        date = Date.parse("#{date}-01-01")
        [date.year, 1]
      elsif date =~ /\A\d{4}-\d{1,2}\z/
        date = Date.parse("#{date}-01")
        [[date.year, date.month], 2]
      else
        raise "Can't parse: #{date.inspect}"
      end
    end
  end

  def match_date?(card_date, query_date, precision)
    return false unless card_date
    if precision == 1
      card_date = card_date.year
    elsif precision == 2
      card_date = [card_date.year, card_date.month]
    end

    case @op
    when "="
      card_date == query_date
    when ">="
      card_date >= query_date
    when ">"
      card_date > query_date
    when "<="
      card_date <= query_date
    when "<"
      card_date < query_date
    else
      raise
    end
  end
end
