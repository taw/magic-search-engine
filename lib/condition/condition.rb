class Condition
  def inspect
    to_s
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
    text.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").strip
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
end
