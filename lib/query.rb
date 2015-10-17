require_relative "query_parser"

class Date
  # Any kind of key for sorting
  def to_i_sort
    to_time.to_i
  end
end

class Query
  def initialize(query_string)
    @cond, @metadata = QueryParser.new.parse(query_string)
    raise unless @cond

    if @metadata[:time]
      @cond = ConditionAnd.new(@cond, ConditionPrint.new("<=", @metadata[:time]))
    end
    @metadata[:no_extras] = !@cond.include_extras?

    # The only part that's used is time
    @cond.metadata = @metadata

    # puts "Parse #{query_string} -> #{@cond}"
  end

  def search(db)
    results = @cond.search(db)
    results = results.reject(&:extra) if @metadata[:no_extras]

    results = case @metadata[:sort]
    when "new"
      results.sort_by{|c| [c.set.regular? ? 0 : 1, -c.release_date.to_i_sort, c.name]}
    when "old"
      results.sort_by{|c| [c.set.regular? ? 0 : 1, c.release_date.to_i_sort, c.name]}
    when "newall"
      results.sort_by{|c| [-c.release_date.to_i_sort, c.name]}
    when "oldall"
      results.sort_by{|c| [c.release_date.to_i_sort, c.name]}
    else # "name" or unknown key
      results.sort_by{|c| [c.name, c.set.regular? ? 0 : 1, -c.release_date.to_i_sort]}
    end
  end

  def to_s
    @cond.to_s
  end
end
