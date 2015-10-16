class ConditionFirstprinted < ConditionPrinted
  def search(db)
    query_date, precision = parse_query_date(db)
    Set.new(db.printings.select{|card| match_date?(card.first_release_date, query_date, precision)})
  end

  def to_s
    "firstprinted#{@op}#{@date}"
  end
end
