require_relative "../format/format"

class ConditionFormat < Condition
  def initialize(format_name)
    @format_name = format_name.downcase.gsub(/\s|-|_/, "")
  end

  def search_all(db)
    format_class = Format[@format_name]
    if format_class == FormatUnknown
      # Otherwise this silently returns nothing, which looks just like a format
      # we support but no card is legal in
      warning %[Unknown format "#{@format_name}"]
      return []
    end
    @format = format_class.new(db.resolve_time(@time))
    # This is just performance hack - Standard/Modern can use this hack
    # Legacy/Vintage/Commander/etc. don't want it
    @format.cards_probably_in_format(db).select{|card| card_ok?(card) }.flat_map(&:printings)
  end

  def metadata!(key, value)
    super
    @time = value if key == :time
  end

  def to_s
    timify_to_s "f:#{maybe_quote(@format_name)}"
  end

  def explain(negated: false)
    timify_explain "the card #{negated ? verb_negated : verb} #{format_display_name}"
  end

  private

  def card_ok?(card)
    @format.legal_or_restricted?(card)
  end

  def verb
    "is legal or restricted in"
  end

  def verb_negated
    "is neither legal nor restricted in"
  end

  # A fresh Format instance just for its display name - cheap, no db needed
  # (same as the one #search_all builds, just without a time to travel to, which
  # #explain never has anyway: #metadata! is what learns @time, and Query#explain
  # never calls it).
  def format_display_name
    return "any format" if @format_name == "*"
    format_class = Format[@format_name]
    return %["#{@format_name}"] if format_class == FormatUnknown
    format_class.new.format_pretty_name
  end
end
