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
      @metadata[:no_extras] = !@cond.include_extras?
      # The only part that's used right now is time
      @cond.metadata = @metadata
    else
      # No search query? OK, we'll just return all cards except extras
      @metadata[:no_extras] = true
    end

    # puts "Parse #{query_string} -> #{@cond}"
  end

  def search(db)
    if @cond
      results = @cond.search(db)
    else
      results = db.printings
    end
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

  def ==(other)
    # structural equality, subclass if you need something fancier
    self.class == other.class and
      instance_variables == other.instance_variables and
      instance_variables.all?{|ivar| instance_variable_get(ivar) == other.instance_variable_get(ivar) }
  end
end
