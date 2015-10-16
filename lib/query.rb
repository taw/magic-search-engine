require_relative "query_parser"

class Query
  def initialize(query_string)
    @cond = QueryParser.new.parse(query_string)
    raise unless @cond
    @no_extras = !@cond.include_extras?
  end

  def match?(card)
    return false if @no_extras and card.extra
    @cond.match?(card)
  end

  def to_s
    @cond.to_s
  end
end
