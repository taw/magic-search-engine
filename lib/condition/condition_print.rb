# This condition checks printing, first/lastprinted check card.
# Should they check same thing?
class ConditionPrint < Condition
  def initialize(op, date, type = '')
    @op = op
    # Just for ConditionPrint#==
    if date.is_a?(Date)
      @date = "%d.%d.%d" % [date.year, date.month, date.day]
    else
      @date = date
    end
    types = {'' => 'full', '*' => 'all', '!' => 'expert'}
    types.default('full')
    @type = types[type]
  end

  def search(db)
    query_date, precision = parse_query_date(db)
    if query_date
      max_date = db.resolve_time(@time)
      ps = db.printings.select{|card| match_date?(get_date(card, max_date), query_date, precision)}.to_set

      # avoid getting an and un confused
      ps.select!{|printing| printing.set_code == @date} if %w(an un).include?(@date)
      ps
    else
      db.printings.to_set
    end
  end

  def to_s
    "print#{@op}#{maybe_quote(@date)}"
  end

  def metadata=(options)
    super
    @time = options[:time]
  end

  private

  # As it operates on printing level not card level we don't need to do any filtering here
  # Query will filter it out anyway. This might need to change if semantics of this filter changes
  def get_date(card, max_date)
    card.release_date
  end

  def parse_query_date(db)
    date = @date
    return [@date, 3] if @date.is_a?(Date)
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
        warning %Q[Doesn't look like correct date, ignored: "#{date}"]
        nil
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
