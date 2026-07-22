class Condition
  def inspect
    to_s
  end

  # Search restricted to a set of printings. The contract is:
  # cond.search(db, candidates) == cond.search(db) & candidates
  #
  # Conditions which don't override #search only know how to search the whole
  # db, so they just throw away whatever isn't in candidates at the end.
  def search(db, candidates=db.printings)
    results = search_all(db)
    return results.to_set if candidates.equal?(db.printings)
    results.to_set & candidates
  end

  # Conditions which don't override #search need to provide this
  def search_all(db)
    raise "SubclassResponsibility"
  end

  # True if #search actually does less work for smaller candidates,
  # instead of searching the whole db and intersecting at the end.
  # ConditionAnd uses this to run such conditions only after the ones
  # which already narrowed the candidate set down for free.
  def uses_candidates?
    false
  end

  # For simple conditions
  # cond.search(db) == db.select{|card| cond.match?(card)}
  # This is extremely relevant for query optimization
  def simple?
    false
  end

  # Save only what's needed, by default nothing
  def metadata!(key, value)
    @logger = value if key == :logger
  end

  def ==(other)
    # structural equality, subclass if you need something fancier
    self.class == other.class and
      instance_variables == other.instance_variables and
      instance_variables.all?{|ivar| instance_variable_get(ivar) == other.instance_variable_get(ivar) }
  end

  def hash
    [
      self.class,
      instance_variables.map{|ivar| [ivar, instance_variable_get(ivar)] }
    ].hash
  end

  def eql?(other)
    self == other
  end

  private

  def normalize_text(text)
    text.downcase.normalize_accents.strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
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

  def warning(warn)
    @logger << warn
  end

  def timify_to_s(str)
    if @time
      "(time:#{maybe_quote(@time)} #{str})"
    else
      str
    end
  end

  def merge_into_set(subresults)
    return subresults[0].to_set if subresults.size == 1

    result = Set[]
    result.merge(*subresults)
    result
  end
end
