class SearchResults
  attr_reader :printings, :warnings

  def initialize(printings, warnings)
    @printings = printings
    @warnings = warnings
  end

  def card_names
    @printings.map(&:name).uniq
  end

  def card_names_and_set_codes
    @printings.group_by(&:name).map{|name, cards| [name, *cards.map(&:set_code).sort]}
  end
end
