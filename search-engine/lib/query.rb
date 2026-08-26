require_relative "query_parser"
require_relative "search_results"
require_relative "sorter"

class Date
  UNIX_EPOCH_JD = Date.new(1970, 1, 1).jd

  # Any kind of key for sorting. Days since the epoch, as the only thing that
  # matters is the order, and every date in the index fits in 15 bits that way.
  # Julian day is what Date stores anyway, so this is also much faster than
  # going through Time.
  def to_i_sort
    jd - UNIX_EPOCH_JD
  end
end

class Query
  attr_reader :warnings, :seed
  attr_reader :cond, :metadata # for tests only

  def initialize(query_string, seed=nil)
    @query_string = query_string
    @cond, @metadata, @warnings = QueryParser.new.parse(query_string)
    if needs_seed?
      @seed = seed || "%016x" % rand(0x1_0000_0000_0000_0000)
    else
      @seed = nil
    end
    @sorter = Sorter.new(@metadata[:sort], @seed)
    @warnings += @sorter.warnings
  end

  def needs_seed?
    @metadata[:sort] && @metadata[:sort] =~ /\b(rand|random)\b/i
  end

  def search(db)
    logger = Set[*@warnings]
    if @cond
      @cond.metadata! :logger, logger
      @cond.metadata! :fuzzy, nil
      # We need to timeout to prevent DOS attacks, but unfortunately this could trigger
      # in a lot of cases we don't want it to, like lazy loading booster data
      # So there should be timeout in the frontend instead
      results = @cond.search(db)
      if results.empty?
        @cond.metadata! :fuzzy, db
        results = @cond.search(db)
      end
    else
      results = db.printings
    end

    SearchResults.new(@sorter.sort(results), logger, ungrouped?)
  end

  def to_s
    str = [
      @cond.to_s,
      # ("time:#{maybe_quote(@metadata[:time])}" if @metadata[:time]),
      ("sort:#{@metadata[:sort]}" if @metadata[:sort]),
      ("view:#{@metadata[:view]}" if @metadata[:view]),
    ].compact.join(" ")
    (@metadata[:ungrouped] ? "++#{str}" : str)
  end

  def ==(other)
    # structural equality, subclass if you need something fancier
    # We ignore @query_string and @seed, so queries that == won't necessarily have same random order
    # It's something we might want to revisit someday
    self.class == other.class and
      instance_variables == other.instance_variables and
      instance_variables.all?{|ivar|
        ivar == :@query_string or
        ivar == :@seed or
        instance_variable_get(ivar) == other.instance_variable_get(ivar)
      }
  end

  def view
    @metadata[:view]
  end

  private

  def ungrouped?
    !!@metadata[:ungrouped]
  end

  def maybe_quote(text)
    if text.is_a?(Date)
      '"%d.%d.%d"' % [text.year, text.month, text.day]
    elsif text =~ /\A[a-zA-Z0-9]+\z/
      text
    else
      text.inspect
    end
  end
end
