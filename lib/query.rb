require_relative "query_parser"

class Query
  def initialize(query_string)
    @query = QueryParser.new.parse(query_string)
    @no_extras = !@query.include_extras?
  end

  def match?(card)
    return false if @no_extras and card.extra
    @query.match?(card)
  end
end
