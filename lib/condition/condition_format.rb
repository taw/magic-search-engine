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
    if @format.format_sets.size < 100
      cards_probably_in_format = @format.format_sets.flat_map do |set_code|
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

  def metadata=(options)
    super
    @time = options[:time]
  end

  def to_s
    "f:#{maybe_quote(@format_name)}"
  end

  private

  def legality_ok?(legality)
    legality == "legal" or legality == "restricted"
  end
end
