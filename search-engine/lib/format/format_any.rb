class FormatAny
  def initialize(time=nil)
    raise ArgumentError unless time.nil? or time.is_a?(Date)
    @formats = Format.all_format_classes.map{|f| f.new(time)}
  end

  def format_pretty_name
    "Any format"
  end

  def banned?(card)
    @formats.any?{|fmt| fmt.banned?(card)}
  end

  def restricted?(card)
    @formats.any?{|fmt| fmt.restricted?(card)}
  end

  def legal?(card)
    @formats.any?{|fmt| fmt.legal?(card)}
  end

  def legal_or_restricted?(card)
    legal?(card) or restricted?(card)
  end

  def included_sets
    nil
  end

  def excluded_sets
    nil
  end
end
