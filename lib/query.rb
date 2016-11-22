require_relative "query_parser"
require_relative "search_results"

class Date
  # Any kind of key for sorting
  def to_i_sort
    to_time.to_i
  end
end

class Query
  def ungrouped?
    !!@metadata[:ungrouped]
  end

  def initialize(query_string)
    @cond, @metadata = QueryParser.new.parse(query_string)

    case @metadata[:time]
    when /\A\d{4}\z/
      # It would probably be easier if we had end-of-period semantics, but we'd need to hack Date.parse for it
      # It parses "March 2010" as "2010.3.1"
      @metadata[:time] = Date.parse("#{@metadata[:time]}.1.1")
    when /\A\d{4}\.\d{1,2}\z/
      @metadata[:time] = Date.parse("#{@metadata[:time]}.1")
    when /\d{4}/
      # throw at Date.parse but only if not set name / symbol
      begin
        @metadata[:time] = Date.parse(@metadata[:time])
      rescue
      end
    else
      # OK
    end

    if @metadata[:time]
      @cond = ConditionAnd.new(@cond, ConditionPrint.new("<=", @metadata[:time]))
    end
    if @cond
      raise "No condition present for #{query_string}" unless @cond
      @metadata[:include_extras] = true if @cond.include_extras?
    else
      # No search query? OK, we'll just return all cards except extras
    end

    # puts "Parse #{query_string} -> #{@cond}"
  end

  # What is being done with @cond.metadata= is awful beyond belief...
  def search(db)
    logger = Set[]
    if @cond
      @cond.metadata = @metadata.merge(fuzzy: nil, logger: logger)
      results = @cond.search(db)
      if results.empty?
        @cond.metadata = @metadata.merge(fuzzy: db, logger: logger)
        results = @cond.search(db)
      end
    else
      results = db.printings
    end
    results = results.reject(&:extra) unless @metadata[:include_extras]

    results = results.sort_by do |c|
      case @metadata[:sort]
      when "new"
        [c.set.regular? ? 0 : 1, -c.release_date.to_i_sort]
      when "old"
        [c.set.regular? ? 0 : 1, c.release_date.to_i_sort]
      when "newall"
        [-c.release_date.to_i_sort]
      when "oldall"
        [c.release_date.to_i_sort]
      when "cmc"
        [c.cmc ? 0 : 1, -c.cmc.to_i]
      when "pow"
        [c.power ? 0 : 1, -c.power.to_i]
      when "tou"
        [c.toughness ? 0 : 1, -c.toughness.to_i]
      else # "name" or unknown key
        []
      end + [c.name, c.set.regular? ? 0 : 1, -c.release_date.to_i_sort, c.set.name, c.number.to_i, c.number]
    end
    SearchResults.new(results, logger)
  end

  def to_s
    [
      @cond.to_s,
      ("time:#{maybe_quote(@metadata[:time])}" if @metadata[:time]),
      ("sort:#{@metadata[:sort]}" if @metadata[:sort]),
    ].compact.join(" ")
  end

  def ==(other)
    # structural equality, subclass if you need something fancier
    self.class == other.class and
      instance_variables == other.instance_variables and
      instance_variables.all?{|ivar| instance_variable_get(ivar) == other.instance_variable_get(ivar) }
  end

  private

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
