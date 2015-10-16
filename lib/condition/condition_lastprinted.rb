class ConditionLastprinted < ConditionPrinted
  def search(db, metadata)
    query_date, precision = parse_query_date(db)
    db.printings.select{|card| match_date?(card.last_release_date, query_date, precision)}.to_set
  end

  def to_s
    "lastprinted#{@op}#{@date}"
  end
end
