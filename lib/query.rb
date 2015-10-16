require_relative "query_parser"

class Query
  def initialize(query_string)
    @cond = QueryParser.new.parse(query_string)
    raise unless @cond
    @no_extras = !@cond.include_extras?
    # puts "Parse #{query_string} -> #{@cond}"
  end

  def search(db)
    results = @cond.search(db)
    results = results.reject(&:extra) if @no_extras
    results.sort
  end

  def to_s
    @cond.to_s
  end
end
