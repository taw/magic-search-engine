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

  private

  def card_ok?(card)
    @format.legal_or_restricted?(card)
  end
end
