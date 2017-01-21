require_relative "../format/format"

class ConditionFormat < Condition
  def initialize(format_name)
    @format_name = format_name.downcase
    @format_name = "commander" if @format_name == "edh"
  end

  def search(db)
    @format = Format[@format_name].new(db.resolve_time(@time))
    # This is just performance hack - Standard/Modern can use this hack
    # Legacy/Vintage/Commander/etc. don't want it
    if @format.included_sets
      cards_probably_in_format = @format.included_sets.flat_map do |set_code|
        # This will only be nil in subset of db, so really only in tests
        set = db.sets[set_code]
        set ? set.printings.map(&:card) : []
      end.to_set
    else
      cards_probably_in_format = db.cards.values
    end
    cards_probably_in_format.select do |card|
      legality_ok?(@format.legality(card))
    end.flat_map(&:printings).to_set
  end

  def metadata!(key, value)
    super
    @time = value if key == :time
  end

  def to_s
    if @time
      "(time:#{maybe_quote(@time)} f:#{maybe_quote(@format_name)})"
    else
      "f:#{maybe_quote(@format_name)}"
    end
  end

  private

  def legality_ok?(legality)
    legality == "legal" or legality == "restricted"
  end
end
