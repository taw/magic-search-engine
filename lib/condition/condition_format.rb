require_relative "../format/format"

class ConditionFormat < Condition
  def initialize(format_name)
    @format_name = format_name.downcase
    @format_name = "commander" if @format_name == "edh"
  end

  def search(db)
    @format = Format[@format_name].new(db.resolve_time(@time))
    db.printings.select do |card|
      legality_ok?(@format.legality(card))
    end.to_set
  end

  def metadata=(options)
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
