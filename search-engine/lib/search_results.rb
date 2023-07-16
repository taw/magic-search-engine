class SearchResults
  attr_reader :printings, :warnings

  def initialize(printings, warnings, ungrouped)
    @printings = printings
    @warnings = warnings
    @ungrouped = ungrouped
  end

  def card_names
    @printings.map(&:name).uniq
  end

  def card_ids
    @printings.map{|c| "#{c.name} [#{c.id}]"}
  end

  def card_names_and_set_codes
    @printings.group_by(&:name).map{|name, cards| [name, *cards.map(&:set_code).sort]}
  end

  def card_groups
    if @ungrouped
      @printings.map{|cp| [cp]}
    else
      @printings.group_by(&:name).values
    end
  end

  def size
    @printings.size
  end
end
